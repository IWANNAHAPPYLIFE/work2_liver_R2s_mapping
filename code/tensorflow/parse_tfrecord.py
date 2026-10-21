import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

#
feature_description = {
    'img_gt': tf.io.FixedLenFeature([], tf.string),
    'map_gt': tf.io.FixedLenFeature([], tf.string),
    'seg': tf.io.FixedLenFeature([], tf.string),
    'tes': tf.io.FixedLenFeature([], tf.string),
    'patient_id': tf.io.FixedLenFeature([], tf.int64),   # 
    'Nx': tf.io.FixedLenFeature([], tf.int64),
    'Ny': tf.io.FixedLenFeature([], tf.int64),
    'Nc': tf.io.FixedLenFeature([], tf.int64),
    'Np': tf.io.FixedLenFeature([], tf.int64),
}

# 
def _parse_function(proto):
    parsed_features = tf.io.parse_single_example(proto, feature_description)

    img_gt = tf.io.parse_tensor(parsed_features['img_gt'], out_type=np.float32)
    map_gt = tf.io.parse_tensor(parsed_features['map_gt'], out_type=np.float32)
    seg = tf.io.parse_tensor(parsed_features['seg'], out_type=np.float32)
    tes = tf.io.parse_tensor(parsed_features['tes'], out_type=np.float32)
    patient_id = parsed_features['patient_id'] #

    Nx = parsed_features['Nx']
    Ny = parsed_features['Ny']
    Nc = parsed_features['Nc']
    Np = parsed_features['Np']

    img_gt = tf.reshape(img_gt, shape=[Nx, Ny, 1])
    map_gt = tf.reshape(map_gt, shape=[Nx, Ny, Np])
    seg = tf.reshape(seg, shape=[Nx, Ny, 1])
    tes = tf.reshape(tes, shape=[Nc])

    return img_gt, map_gt, seg, tes,  patient_id, Nx, Ny, Nc, Np

# 
def load_tfrecord_dataset(file_path):
    dataset = tf.data.TFRecordDataset(file_path)
    dataset = dataset.map(_parse_function)
    return dataset

#
if __name__ == '__main__':
 
    tfrecord_path = '/root/autodl-tmp/data_noise_free.tfrecords'

    # 
    dataset = load_tfrecord_dataset(tfrecord_path)

    # 
    for idx, sample in enumerate(dataset.take(5)):  # 
        print(f"\n【Sample {idx + 1}】")

        # 
        img_gt, map_gt, seg, tes, patient_id, Nx, Ny, Nc, Np = sample

        #
        img_gt_np = img_gt.numpy()
        map_gt_np = map_gt.numpy()
        seg_np = seg.numpy()
        tes_np = tes.numpy()
        patient_id_np = patient_id.numpy()

        # 
        print(f"Patient ID: {patient_id_np}")
        print(f"Nx: {Nx.numpy()}, Ny: {Ny.numpy()}, Nc: {Nc.numpy()}, Np: {Np.numpy()}")
        print(f"img_gt shape: {img_gt_np.shape}")
        print(f"map_gt shape: {map_gt_np.shape}")
        print(f"seg shape: {seg_np.shape}")
        print(f"tes shape: {tes_np.shape}")
        print(f"tes values: {tes_np}")


        fig, axes = plt.subplots(1, 3, figsize=(15, 5))  #

        # img_gt
        axes[0].imshow(img_gt_np[:, :, 0], cmap='gray')
        axes[0].set_title('Image GT')
        axes[0].axis('off')

        # seg
        axes[1].imshow(seg_np[:, :, 0], cmap='gray')
        axes[1].set_title('Segmentation')
        axes[1].axis('off')

       
        axes[2].imshow(map_gt_np[:, :, 0], cmap='hot')  # 
        axes[2].set_title('Map GT (Channel 0)')
        axes[2].axis('off')

        plt.suptitle(f"Sample {idx+1} - Patient ID: {patient_id_np}")
        plt.tight_layout()
        plt.show()