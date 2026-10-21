import importlib
import os
import tensorflow as tf
# tf.config.run_functions_eagerly(True)  # 

import mmpm as net  # 
importlib.reload(net)  #
import functions as func
import tensorflow as tf
import os
import numpy as np
import matplotlib.pyplot as plt
def extract(img_gt, s0_gt, r2_gt, seg, rician, tau,
            id_tau=[], rescale=100.0, model_type='unrolling', data_type='mono', task='R2mapping'):

    '''
    Extract partial data to train the network, and rescale the parameters.
    - rescale, rescale the T2/T1 values to about 1, to accelerate the training.
    '''
    if len(id_tau) != 0: #
       
        img_gt = tf.gather(img_gt,indices=id_tau,axis=-1)  #
        rician  = tf.gather(rician,indices=id_tau,axis=-1) # 
        tau = tf.gather(tau,indices=id_tau,axis=-1)

    if task == 'T2mapping':
        A  = map_gt[...,0]
        R2 = tf.math.divide_no_nan(rescale,map_gt[...,1])
        map_gt = tf.stack((A,R2),axis=-1)

    if task == 'R2mapping':
        # s0 = s0_gt
        # r2 = r2_gt
        s0 = tf.squeeze(s0_gt, axis=-1)
        r2 = tf.squeeze(r2_gt, axis=-1)
        map_gt = tf.stack([s0, r2], axis=-1)  # shape: (H, W, Np, 2)
        # tf.print('gg',tf.shape(map_gt))
    tau = tau/rescale  #
    # tf.print("tau是", tau)

    # 
    mask = tf.where(seg > 0.0,1.0,0.0)
    map_gt = map_gt*mask
    # tf.print('map_gt is', tf.shape(map_gt)) # (64,64,2)
    rician = rician*mask
    img_gt = img_gt*mask

    # mono-exponential
    if data_type == 'mono':  rician,img_gt = img_gt,rician
    # output data according to network type.
    if model_type == 'unrolling': return ((img_gt,tau),map_gt) # rician is (64, 64, 12),tau is [0.002325 0.005675 0.009025 ... 0.033 0.0365 0.04], map_gt is (64,64,2)
    if model_type == 'cnn':       return (imgs_n,map_gt)
    if model_type == 'test':      return ((imgs_n,tau),map_gt,seg)

feature_description = {
    'img_gt': tf.io.FixedLenFeature([], tf.string),
    's0_gt': tf.io.FixedLenFeature([], tf.string),
    'r2_gt': tf.io.FixedLenFeature([], tf.string),

    'seg': tf.io.FixedLenFeature([], tf.string),
    
    'rician': tf.io.FixedLenFeature([], tf.string),
    'tes': tf.io.FixedLenFeature([], tf.string),
    'Nx': tf.io.FixedLenFeature([], tf.int64),
    'Ny': tf.io.FixedLenFeature([], tf.int64),
    'Nc': tf.io.FixedLenFeature([], tf.int64),
    'Np': tf.io.FixedLenFeature([], tf.int64),
}
def parse_all(proto):
    parsed_features = tf.io.parse_single_example(proto, feature_description)
  
    img_gt = tf.io.parse_tensor(parsed_features['img_gt'], out_type=np.float32)
    s0_gt = tf.io.parse_tensor(parsed_features['s0_gt'], out_type=np.float32)
    r2_gt = tf.io.parse_tensor(parsed_features['r2_gt'], out_type=np.float32)

#
    seg = tf.io.parse_tensor(parsed_features['seg'], out_type=np.float32)
    rician = tf.io.parse_tensor(parsed_features['rician'], out_type=np.float32)
    tes = tf.io.parse_tensor(parsed_features['tes'], out_type=np.float32)
    # tf.print("tes shape是:", tf.shape(tes))  # [12]
    # tf.print("tes是:", tes)  
  
    Nx = parsed_features['Nx']
    Ny = parsed_features['Ny']
    Nc = parsed_features['Nc']
    Np = parsed_features['Np']
    

    img_gt = tf.reshape(img_gt, shape=[Nx, Ny, Nc])
    
    s0_gt = tf.reshape(s0_gt, shape=[Nx, Ny, 1])  # 
    r2_gt = tf.reshape(r2_gt, shape=[Nx, Ny, 1])
    

    seg = tf.reshape(seg, shape=[Nx, Ny, 1])
    rician = tf.reshape(rician, shape=[Nx, Ny, Nc])
    # print('rician',rician.shape)
    # tf.print("rician shape:", tf.shape(rician))  # 使用 tf.print + tf.shape
    tes = tf.reshape(tes, shape=[Nc])

    return img_gt, s0_gt, r2_gt, seg, rician, tes

# ####
def load_custom_data(train_file, valid_file, id_tau, rescale_para, type_task):
    dataset_train = tf.data.TFRecordDataset(tf.io.gfile.glob(train_file)) \
                      .map(parse_all) \
                      .map(lambda x1, x2, x3, x4, x5,x6: extract(
                          x1, x2, x3, x4, x5,x6,
                          id_tau=id_tau,
                          rescale=rescale_para,
                          model_type='unrolling',
                          data_type='mono',
                          task=type_task))

    dataset_valid = tf.data.TFRecordDataset(tf.io.gfile.glob(valid_file)) \
                      .map(parse_all) \
                      .map(lambda x1, x2, x3, x4, x5,x6: extract(
                          x1, x2, x3, x4, x5,x6,
                          id_tau=id_tau,
                          rescale=rescale_para,
                          model_type='unrolling',
                          data_type='mono',
                          task=type_task))

    dataset_train_size = sum(1 for _ in tf.data.TFRecordDataset(tf.io.gfile.glob(train_file)))
    dataset_valid_size = sum(1 for _ in tf.data.TFRecordDataset(tf.io.gfile.glob(valid_file)))

    print('-' * 98)
    print('Training data path:', train_file)
    print('Validation data path:', valid_file)
    print('Training data size:', dataset_train_size)
    print('Validation data size:', dataset_valid_size)

 
    return dataset_train, dataset_valid, dataset_train_size, dataset_valid_size

### 
###$###################################################
id_tau = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] # [0, 1, ..., 11]

# 
sigma = 'rician'

#
rescale_para =400  #
# 
type_task = 'R2mapping'

# 
train_file = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/train/traindata.tfrecords'
valid_file = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/valid/validdata.tfrecords'
dataset_train, dataset_valid, dataset_train_size, dataset_valid_size = load_custom_data(
    train_file = train_file,
    valid_file = valid_file,
    id_tau = id_tau,
    rescale_para = rescale_para,
    type_task = type_task
)

# print('dataset_train为：', dataset_train)
print('='*98)
print('===== ', type_task, ' =====')
print('Load data ...')


###
##
###
print('Create model ...')


Nc = len(id_tau)       # 
Ns = 10              # 
Nk = 5                # 
Nt = 1                 #
ini_lam, ini_rho = 0.001, 0.1  # 
signed = 0             # 
Np, sep, f = 2, 0, 3   # 


# 
nn = net.MMPM_Net(Ns=Ns, Nk=Nk, Nt=Nt, Np=Np, signed=signed, sep=sep, f=f,
                  ini_lam=ini_lam, ini_rho=ini_rho, test_mode=False, name='MMPM_Net')

inpt_b   = tf.keras.layers.Input(shape=(None, None, Nc), name='images') #
inpt_tau = tf.keras.layers.Input(shape=(Nc,), name='tes')



para_map = nn([inpt_b, inpt_tau]) #
print('para_map',para_map.shape)  


model = tf.keras.Model(inputs=[inpt_b, inpt_tau], outputs=para_map)  #
# 
model.summary()


####
batch_size = 32
epochs = 200
save_every = 50
validation_batch_size = batch_size
ini_lr = 0.001


steps_per_epoch = tf.math.floor(dataset_train_size / batch_size)

validation_steps = tf.math.floor(dataset_valid_size / validation_batch_size)

suffix = 'lam_{}_rho_{}_bs_{}_maemow_lr_{}'.format(ini_lam, ini_rho, batch_size, ini_lr)
model_dir = os.path.join('model', type_task, 'mmpm_net',
                         'mmpm_net_Ns_{}_Nk_{}_Nt_{}_signed_{}_sigma_{}_{}'.format(
                             Ns, Nk, Nt, signed, sigma, suffix))

print(model_dir)
print('-'*98)


initial_epoch = func.findLastCheckpoint(save_dir=model_dir)
if initial_epoch > 0:
    print('Resuming by loading epoch %03d' % initial_epoch)
    model.load_weights(os.path.join(model_dir, 'model_%03d.h5' % initial_epoch))


opti = tf.keras.optimizers.Adam(learning_rate=ini_lr)  # 
loss = func.MAE_mow()  # 
metric = [func.NRMSE_metric]  # 

model.compile(optimizer=opti, loss=loss, metrics=metric)



class EpochCheckpoint(tf.keras.callbacks.Callback):
    def __init__(self, save_every, model_dir):
        super().__init__()
        self.save_every = save_every
        self.model_dir = model_dir

    def on_epoch_end(self, epoch, logs=None):
        if (epoch + 1) % self.save_every == 0:
            filename = os.path.join(self.model_dir, f'model_{epoch + 1:03d}.h5')
            self.model.save_weights(filename)
            print(f'\n✅ Saved model at epoch {epoch + 1} to {filename}')

checkpointer = EpochCheckpoint(save_every=50, model_dir=model_dir)

csv_logger = tf.keras.callbacks.CSVLogger(os.path.join(model_dir, 'log.csv'), append=True, separator=',')

tensorboard = tf.keras.callbacks.TensorBoard(log_dir=model_dir, histogram_freq=1)

lr_scheduler = tf.keras.callbacks.LearningRateScheduler(func.lr_schedule)

print('=' * 98)
print('Check dataset output structure and shapes:')



###
model.fit(
    x = dataset_train.repeat(epochs).batch(batch_size, drop_remainder = True),
    validation_data = dataset_valid.batch(validation_batch_size),
    epochs = epochs,
    steps_per_epoch = int(steps_per_epoch),
    validation_steps = int(validation_steps),
    callbacks = [checkpointer, csv_logger, tensorboard, lr_scheduler],
    
    initial_epoch = initial_epoch
)
