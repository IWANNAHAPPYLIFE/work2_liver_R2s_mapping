import tensorflow as tf

class range_constaint_R2(tf.keras.layers.Layer):
    """
    Range constraint for R2* mapping.
    Ensures 0 <= m0 <= m0_max, 0 <= p2 <= p2_max.
    """
    def __init__(self, m0_max=3.0, p2_max=300.0, name=None):
        super().__init__(name=name)
        self.m0_max = m0_max
        self.p2_max = p2_max

    def call(self, x):
        # 
        x = tf.math.maximum(x, 0.0)

        # 
        m0, p2 = tf.split(x, 2, axis=-1)

        # 
        m0 = tf.math.minimum(m0, self.m0_max)
        p2 = tf.math.minimum(p2, self.p2_max)

        # 
        x = tf.concat([m0, p2], axis=-1)
        return x



class physical_model_R2(tf.keras.layers.Layer):
    """Forward model for R2* mapping: S(TE) = m0 * exp(-p2 * TE)."""
    def __init__(self, name="R2_decay"):
        super(physical_model_R2, self).__init__(name=name)

    def call(self, inputs):
        x, tau = inputs   # x: [Nb, Ny, Nx, 2], tau: [Nq]
        m0, p2 = tf.split(x, 2, axis=-1)     # m0, p2
        # tau    = tf.reshape(tau, shape=(1,1,1,-1))  # [Nq] → [1,1,1,Nq]
        tau = tf.reshape(tau, shape=(1, -1))   
        S      = m0 * tf.exp(-p2 * tau)      # [Nb, Ny, Nx, Nq]
        return S


class min_value(tf.keras.constraints.Constraint):
    """Constraints value to be high than `ref_value`."""
    def __init__(self,ref_value):
        self.ref_value = ref_value
    
    def __call__(self, w):
        return tf.math.maximum(self.ref_value, w)

# import tensorflow as tf
# # tf.config.run_functions_eagerly(True)



# def range_constraint_R2(x, s0_max=1.0, r2_max=1.0):
#     """

#     """
#     x = tf.math.maximum(x, 0.0)  # 
#     s0, r2 = tf.split(x, 2, axis=-1) 
#     s0 = tf.clip_by_value(s0, 0.0, s0_max)
#     r2 = tf.clip_by_value(r2, 0.0, r2_max)
#     x = tf.concat([s0, r2], axis=-1)
#     return x


# class range_constraint_R2(tf.keras.layers.Layer):
#     '''
#     T2 relaxation model layer.
#  
#     ''
#     def __init__(self, s0_max=1.0, r2_max=1.0, name=None):
#         super(range_constraint_R2, self).__init__(name=name)
#         self.s0_max = s0_max
#         self.r2_max = r2_max

#     def call(self, x):
#         x = tf.math.maximum(x, 0.0)  # 
#         s0, r2 = tf.split(x, 2, axis=-1)
#         s0 = tf.clip_by_value(s0, 0.0, self.s0_max)
#         r2 = tf.clip_by_value(r2, 0.0, self.r2_max)
#         x = tf.concat([s0, r2], axis=-1)
#         return x
    
    
    
# class physical_model(tf.keras.layers.Layer):
    
#     def __init__(self, name=None):
#         super(physical_model, self).__init__(name=name)
    
#     def call(self, x, tau): ## x_vec (8192,2), tau0(12,)一行12列
#         """
#   ：
#         S(TE) = S0 * exp(-TE * R2*)

#         Parameters:
#             x:   [N, Np] 
#             tau:  [Nq]

#         Returns:
#             s:  [B, H, W, Nq]
#         """
#         x = tf.math.abs(x)
#         s0, r2_star = tf.split(x, num_or_size_splits=2, axis=-1)  # [8192,1]
#         # tf.print('000',tf.shape(s0))  # [8192,1]
    
        
#         tau = tf.reshape(tau, shape=(1, -1))          
#         # tf.print('ttt',tf.shape(tau)) # 1，12]
#         s = s0 * tf.exp(-tau * r2_star)  # -tau * r2_star(8192, 12)；tf.exp(-tau * r2_star)  # shape: (8192, 12)；s.shape == (8192, 12)
      
#         # tf.print('sss',tf.shape(s))   # （none.none.,none,12)(none,12)==>[8192,12]
#         return s
# import tensorflow as tf
# tf.config.run_functions_eagerly(True)


