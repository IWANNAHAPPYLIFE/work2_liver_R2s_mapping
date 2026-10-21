# ==== Inference script with corrected extract function integration ====

import os
import numpy as np
import tensorflow as tf
import importlib
import matplotlib.pyplot as plt
import mmpm as net
import functions as func

importlib.reload(net)
importlib.reload(func)

# ==== Config ====
id_tau = list(range(12))  # TE indices used
rescale_para = 400
type_task = 'R2mapping'
Nc = len(id_tau)

# Model parameters (must match training)
Ns, Nk, Nt = 10, 5, 1
Np, sep, f = 2, 0, 3
signed = 0
batch_size = 1

model_dir = 'model/R2mapping/mmpm_net/mmpm_net_Ns_10_Nk_5_Nt_1_signed_0_sigma_rician_lam_0.001_rho_0.1_bs_32_maemow_lr_0.001'
weight_file = os.path.join(model_dir, 'model_200.h5')
infer_file = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/test/testdata.tfrecords'
result_dir = 'results/inference'
os.makedirs(result_dir, exist_ok=True)

# ==== Feature parsing ====
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
    
    img_gt = tf.io.parse_tensor(parsed_features['img_gt'], out_type=tf.float32)
    s0_gt = tf.io.parse_tensor(parsed_features['s0_gt'], out_type=tf.float32)
    r2_gt = tf.io.parse_tensor(parsed_features['r2_gt'], out_type=tf.float32)
    seg = tf.io.parse_tensor(parsed_features['seg'], out_type=tf.float32)
    rician = tf.io.parse_tensor(parsed_features['rician'], out_type=tf.float32)
    tes = tf.io.parse_tensor(parsed_features['tes'], out_type=tf.float32)

    Nx = parsed_features['Nx']
    Ny = parsed_features['Ny']
    Nc = parsed_features['Nc']
    Np = parsed_features['Np']

    tf.print(">>> actual img_gt shape:", tf.shape(img_gt))
    tf.print(">>> target shape:", Nx, Ny, Nc)
    tf.print("Nx, Ny, Nc:", Nx, Ny, Nc)
    tf.print("img_gt shape before reshape:", tf.shape(img_gt))
    tf.print("img_gt flattened size:", tf.size(img_gt))



    img_gt = tf.reshape(img_gt, shape=[Nx, Ny, Nc])
    s0_gt = tf.reshape(s0_gt, shape=[Nx, Ny, 1])
    r2_gt = tf.reshape(r2_gt, shape=[Nx, Ny, 1])
    seg = tf.reshape(seg, shape=[Nx, Ny, 1])
    rician = tf.reshape(rician, shape=[Nx, Ny, Nc])
    tes = tf.reshape(tes, shape=[Nc])

    return img_gt, s0_gt, r2_gt, seg, rician, tes


# ==== Extract function ====
def extract(img_gt, s0_gt, r2_gt, seg, rician, tau,
            id_tau, rescale, model_type='unrolling', data_type='mono', task='R2mapping'):

    img_gt = tf.gather(img_gt, id_tau, axis=-1)
    rician = tf.gather(rician, id_tau, axis=-1)
    tau = tf.gather(tau, id_tau)

    s0 = tf.squeeze(s0_gt, axis=-1)
    r2 = tf.squeeze(r2_gt, axis=-1)
    map_gt = tf.stack([s0, r2], axis=-1)

    tau = tau / rescale
    mask = tf.where(seg > 0.0, 1.0, 0.0)
    map_gt *= mask
    img_gt *= mask
    rician *= mask

    if data_type == 'mono':
        rician, img_gt = img_gt, rician

    if model_type == 'unrolling':
        return (img_gt, tau), map_gt
    else:
        raise ValueError('Unsupported model_type')

def extract_data(img_gt, s0_gt, r2_gt, seg, rician, tes):
    return extract(img_gt, s0_gt, r2_gt, seg, rician, tes,
                   id_tau=id_tau, rescale=rescale_para,
                   model_type='unrolling', data_type='mono', task=type_task)

# ==== Prepare dataset ====
dataset = tf.data.TFRecordDataset(tf.io.gfile.glob(infer_file))
parsed_dataset = dataset.map(parse_all).map(extract_data).batch(batch_size)

# ==== Model ==== 
nn = net.MMPM_Net(Ns=Ns, Nk=Nk, Nt=Nt, Np=Np, signed=signed, sep=sep, f=f,
                  ini_lam=0.001, ini_rho=0.1, test_mode=True, name='MMPM_Net')
inpt_b = tf.keras.layers.Input(shape=(None, None, Nc))
inpt_tau = tf.keras.layers.Input(shape=(Nc,))
out_map = nn([inpt_b, inpt_tau])
model = tf.keras.Model(inputs=[inpt_b, inpt_tau], outputs=out_map)

if os.path.exists(weight_file):
    model.load_weights(weight_file)
    print(f"Loaded weights from {weight_file}")
else:
    raise FileNotFoundError(f"权重文件未找到: {weight_file}")

# ==== Inference Loop ====
def normalize(img):
    return (img - np.min(img)) / (np.max(img) - np.min(img) + 1e-8)

for idx, batch in enumerate(parsed_dataset.take(10)):
    inputs, labels = batch
    b, tau = inputs
    map_gt = labels.numpy()

    maps_pred = model.predict((b, tau), verbose=0)
    final_map = maps_pred[-1]

    s0_pred = final_map[..., 0].squeeze()
    r2_pred = final_map[..., 1].squeeze()
    s0_gt = map_gt[..., 0].squeeze()
    r2_gt = map_gt[..., 1].squeeze()

    s0_err = np.abs(s0_pred - s0_gt)
    r2_err = np.abs(r2_pred - r2_gt)

    np.save(os.path.join(result_dir, f's0_pred_{idx}.npy'), s0_pred)
    np.save(os.path.join(result_dir, f'r2_pred_{idx}.npy'), r2_pred)
    np.save(os.path.join(result_dir, f's0_error_{idx}.npy'), s0_err)
    np.save(os.path.join(result_dir, f'r2_error_{idx}.npy'), r2_err)

    # Visualization
    plt.figure(figsize=(12, 6))
    titles = ["S0 Prediction", "R2 Prediction", "S0 GT", "R2 GT", "S0 Error", "R2 Error"]
    images = [s0_pred, r2_pred, s0_gt, r2_gt, s0_err, r2_err]
    cmaps = ['gray', 'jet', 'gray', 'jet', 'jet', 'jet']
    for i in range(6):
        plt.subplot(2, 3, i+1)
        plt.imshow(normalize(images[i]), cmap=cmaps[i])
        plt.title(titles[i])
        plt.axis('off')
    plt.tight_layout()
    plt.savefig(os.path.join(result_dir, f'result_{idx}.png'))
    plt.close()
    print(f"Saved inference results for sample {idx}")

print("Inference done.")
