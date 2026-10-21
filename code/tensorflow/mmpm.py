
import tensorflow as tf
import denoiser
import auxiliary_functions as afunc

class ReconBlock(tf.keras.layers.Layer):
    """Gaussian-Newton reconstruction block for T2 mapping"""
    def __init__(self, signed=True, name=None):
        super(ReconBlock, self).__init__(name=name)
        # 
        self.relax = afunc.physical_model_R2(name='T2_decay')

    @tf.function
    def jaco(self, x_vec, tau0):
        """Automatic differentiation Jacobian"""
        with tf.GradientTape(persistent=True) as g:
            g.watch(x_vec)
            s = self.relax([x_vec, tau0])  # [N, Nq]
        ds_dx = g.batch_jacobian(s, x_vec)  # [N, Nq, Np]
        return ds_dx

    @tf.function
    def call(self, x, z, beta, rho, sigma, b, tau):
        Nb, Ny, Nx, Np = tf.shape(x)[0], tf.shape(x)[1], tf.shape(x)[2], tf.shape(x)[3]
        Nq = tf.shape(tau)[-1]

        tau0 = tau[0]  # [Nq]

        # Jacobian
        x_vec = tf.reshape(x, (-1, Np))
        ds_dx = self.jaco(x_vec, tau0)
        ds_dx = tf.reshape(ds_dx, (Nb, Ny, Nx, Nq, Np))

        # Gradient
        s = self.relax([x, tau0])  # [Nb, Ny, Nx, Nq]
        r = tf.expand_dims(s - b, axis=-1)  # [Nb, Ny, Nx, Nq, 1]
        grad1 = tf.reduce_mean(ds_dx * r, axis=-2)  # [Nb, Ny, Nx, Np]
        grad2 = rho * (x + beta - z)
        grad = grad1 + grad2  # [Nb, Ny, Nx, Np]

        # Hessian
        ds_dx = tf.expand_dims(ds_dx, axis=-1)  # [Nb, Ny, Nx, Nq, Np, 1]
        JTJ = tf.linalg.matmul(ds_dx, ds_dx, transpose_b=True)  # [Nb, Ny, Nx, Nq, Np, Np]
        JTJ = tf.reduce_mean(JTJ, axis=-3)  # [Nb, Ny, Nx, Np, Np]
        H = JTJ + rho * tf.eye(Np)
        eps = 1e-5 * tf.eye(Np)
        H = H + eps
        H_inv = tf.linalg.inv(H)
        idx_in = tf.where(tf.linalg.det(H) <= 0.0, 0.0, 1.0)[..., tf.newaxis, tf.newaxis]
        H_inv = H_inv * idx_in

        grad = tf.expand_dims(grad, axis=-1)
        d = tf.linalg.matmul(H_inv, grad)
        d = tf.squeeze(d, axis=-1)
        x = x - d
        return x


class AuxVarBlock(tf.keras.layers.Layer):  ##
    """Auxiliary variable update block"""
    def __init__(self, name=None):
        super(AuxVarBlock, self).__init__(name=name)

    def call(self, x, z, beta, rho, lam, fz):
        z_1 = rho * (x + beta)
        z_2 = lam * fz
        z_3 = (z_1 + z_2) / (rho + lam)
        return z_3


class MMPM_Net(tf.keras.layers.Layer):
    """Multi-Stage Model-Based Parameter Mapping Network for T2 mapping"""
    def __init__(self, Ns=10, Nk=1, Nt=1, Np=2, signed=True, f=3, sep=False,
                 ini_lam=0.001, ini_rho=0.1, test_mode=False, name=None):
        super(MMPM_Net, self).__init__(name=name)

        self.Ns = Ns
        self.Nk = Nk
        self.Nt = Nt
        self.tmode = test_mode
        self.sep = sep

        # Learnable parameters
        self.lam = tf.Variable(initial_value=ini_lam, trainable=True,
                               name=name+'_lam', constraint=afunc.min_value(0.001))
        self.rho = tf.Variable(initial_value=ini_rho, trainable=True,
                               name=name+'_rho', constraint=afunc.min_value(0.001))
        self.sigma = tf.Variable(initial_value=1.0, trainable=False,
                                 name=name+'_sigma', constraint=tf.keras.constraints.NonNeg())

        # Blocks
        self.reconblock = ReconBlock(signed=signed, name='recon')
        self.auxvarblock = AuxVarBlock(name='auxvar')
        self.range_cons = afunc.range_constaint_R2(m0_max=3.0, p2_max=10.0)
####cnn
# #         # Denoiser
        if self.sep:
            self.denoiser = []
            for i in range(Np):
                self.denoiser.append(denoiser.CNN(Nconv=7, Np=1, filters=64, f=f,
                                                  name=f'denoiser_{i}'))
        else:
            self.denoiser = denoiser.CNN(Nconv=7, Np=Np, filters=64, f=f, name='denoiser')
        # Denoiser
        # if self.sep:
        #     self.denoiser = []
        #     for i in range(Np):
        #         self.denoiser.append(
        #             denoiser.UNet(Np=1, filters=64, name=f'unet_{i}')
        #         )
        # else:
        #     self.denoiser = denoiser.UNet(Np=Np, filters=64, name='unet')##17个权重
# # #### MOLED

 # Denoiser
        # if self.sep:
        #     self.denoiser = []
        #     for i in range(Np):
        #         self.denoiser.append(denoiser.MOLED(Nblock=7, Np=1, filters=64, f=f,
        #                                           name=f'denoiser_{i}'))
        # else:
        #     self.denoiser = denoiser.MOLED(Nblock=7, Np=Np, filters=64, f=f, name='denoiser')


    def call(self, inputs):
        b, tau = inputs
        xm = []

        # Initialization
        M0 = tf.reduce_max(tf.abs(b), axis=-1)
        R2 = tf.ones_like(M0) * 1.0
        x = tf.stack([M0, R2], axis=-1)
        x = self.range_cons(x)
        z = x
        beta = tf.zeros_like(x)

        if self.tmode:
            xm.append(x)

        # Initial reconstruction
        for _ in range(self.Nk):
            x = self.reconblock(x, z, beta, 0.0, self.sigma, b, tau)
            x = self.range_cons(x)
        z = x
        beta = tf.zeros_like(x)

        if self.tmode:
            xm.append(x)

        # Main iterations
        for _ in range(self.Ns):
            # Reconstruction
            for _ in range(self.Nk):
                x = self.reconblock(x, z, beta, self.rho, self.sigma, b, tau)
                x = self.range_cons(x)
            xm.append(x)

            # Auxiliary variable update
            for _ in range(self.Nt):
                if self.sep:
                    z0, z1 = tf.split(z, 2, axis=-1)
                    z0 = self.denoiser[0](z0)
                    z1 = self.denoiser[1](z1)
                    fz = tf.concat([z0, z1], axis=-1)
                else:
                    fz = self.denoiser(z)

                z = self.auxvarblock(x, z, beta, self.rho, self.lam, fz)
                z = self.range_cons(z)

            beta = x + beta - z

        if not self.tmode:
            xm.append(x)

        return tf.stack(xm)
