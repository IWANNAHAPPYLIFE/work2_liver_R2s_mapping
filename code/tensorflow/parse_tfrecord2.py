import os
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt


feature_description = {
    'img_gt': tf.io.FixedLenFeature([], tf.string),
    'map_gt': tf.io.FixedLenFeature([], tf.string),
    'rician': tf.io.FixedLenFeature([], tf.string),
    'seg': tf.io.FixedLenFeature([], tf.string),
    'tes': tf.io.FixedLenFeature([], tf.string),  #
    'Nx': tf.io.FixedLenFeature([], tf.int64),
    'Ny': tf.io.FixedLenFeature([], tf.int64),
    'Nc': tf.io.FixedLenFeature([], tf.int64),
    'Np': tf.io.FixedLenFeature([], tf.int64),
}


def _parse_function(proto):
    parsed_features = tf.io.parse_single_example(proto, feature_description)
    img_gt = tf.io.parse_tensor(parsed_features['img_gt'], out_type=tf.float32)
    map_gt = tf.io.parse_tensor(parsed_features['map_gt'], out_type=tf.float32)
    rician = tf.io.parse_tensor(parsed_features['rician'], out_type=tf.float32)
    seg = tf.io.parse_tensor(parsed_features['seg'], out_type=tf.float32)
    tes = tf.io.parse_tensor(parsed_features['tes'], out_type=tf.float32)  # 
    Nx = parsed_features['Nx']
    Ny = parsed_features['Ny']
    Nc = parsed_features['Nc']
    Np = parsed_features['Np']
    img_gt = tf.reshape(img_gt, shape=[Nx, Ny, Nc])
    map_gt = tf.reshape(map_gt, shape=[Nx, Ny, Np])
    rician = tf.reshape(rician, shape=[Nx, Ny, Nc])
    seg = tf.reshape(seg, shape=[Nx, Ny, 1])
    return img_gt, map_gt, rician, seg, tes

# 
def load_tfrecord_dataset(file_path):
    dataset = tf.data.TFRecordDataset(file_path)
    dataset = dataset.map(_parse_function)
    return dataset

# 
def visualize_samples(img_gt, map_gt, rician, seg, tes, num_samples=21):
    for idx in range(num_samples):
        print(f"\n【Sample {idx + 1}】")

        # 
        img_gt_sample = img_gt[idx, :, :, 0]  # 
        map_gt_sample = map_gt[idx, :, :, 0]
        rician_sample = rician[idx, :, :, 0]
        seg_sample = seg[idx, :, :, 0]
        te_sample = tes[idx]  # 
        #
        fig, axes = plt.subplots(1, 4, figsize=(20, 6))

        # img_gt
        axes[0].imshow(img_gt_sample, cmap='gray')
        axes[0].set_title('Image GT')
        axes[0].axis('off')

        # map_gt
        axes[1].imshow(map_gt_sample, cmap='jet')  # 
        axes[1].set_title('Map GT')
        axes[1].axis('off')

        # rician
        axes[2].imshow(rician_sample, cmap='gray')
        axes[2].set_title('Rician Noise')
        axes[2].axis('off')
        
        # seg
        axes[3].imshow(seg_sample, cmap='gray')
        axes[3].set_title('Mask')
        axes[3].axis('off')

        plt.suptitle(f"Sample {idx + 1} - TE: {te_sample}")
        plt.tight_layout()
        plt.show()

#
if __name__ == '__main__':
    # 
    tfrecord_path = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/T2mapping/trainingdata/traindata.tfrecord'

    #
    dataset = load_tfrecord_dataset(tfrecord_path)

    # 
    img_gt_list, map_gt_list, rician_list, seg_list, tes_list = [], [], [], [], []
    for sample in dataset:
        img_gt, map_gt, rician, seg, tes = sample
        img_gt_list.append(img_gt.numpy())
        map_gt_list.append(map_gt.numpy())
        rician_list.append(rician.numpy())
        seg_list.append(seg.numpy())
        tes_list.append(tes.numpy())  # 

    # 
    img_gt_np = np.array(img_gt_list)
    map_gt_np = np.array(map_gt_list)
    rician_np = np.array(rician_list)
    seg_np = np.array(seg_list)
    tes_np = np.array(tes_list)  #

    # 
    visualize_samples(img_gt_np, map_gt_np, rician_np, seg_np, tes_np, num_samples=21)