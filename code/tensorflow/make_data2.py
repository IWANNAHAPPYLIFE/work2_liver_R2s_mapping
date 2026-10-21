###获得20组12回波的patches
import os
import numpy as np
import tensorflow as tf

# 
def data_aug(patch, mask_patch, map_patch, rician_patch, mode):
    if mode == 1:  # 
        return np.fliplr(patch), np.fliplr(mask_patch), np.fliplr(map_patch), np.fliplr(rician_patch)
    elif mode == 2:  # 
        return np.flipud(patch), np.flipud(mask_patch), np.flipud(map_patch), np.flipud(rician_patch)
    elif mode == 3:  # 
        return np.rot90(patch, 2), np.rot90(mask_patch, 2), np.rot90(map_patch, 2), np.rot90(rician_patch, 2)
    else:
        return patch, mask_patch, map_patch, rician_patch

#
def extract_patches(image, mask, map_data, rician_norm, tes, patch_size=64, stride=16, roi_threshold=0.1, aug_times=3):
    h, w, c = image.shape
    patches, mask_patches, map_patches, rician_patches = [], [], [], []
    tes_values = []

    for i in range(0, h - patch_size + 1, stride):
        for j in range(0, w - patch_size + 1, stride):
            patch = image[i:i + patch_size, j:j + patch_size, :]
            mask_patch = mask[i:i + patch_size, j:j + patch_size]
            map_patch = map_data[i:i + patch_size, j:j + patch_size, :]
            rician_patch = rician_norm[i:i + patch_size, j:j + patch_size, :]

            if np.mean(mask_patch) > roi_threshold:
                patches.append(patch)
                mask_patches.append(mask_patch)
                map_patches.append(map_patch)
                rician_patches.append(rician_patch)

                for mode in range(1, aug_times + 1):
                    aug_patch, aug_mask_patch, aug_map_patch, aug_rician_patch = data_aug(patch, mask_patch, map_patch, rician_patch, mode)
                    patches.append(aug_patch)
                    mask_patches.append(aug_mask_patch)
                    map_patches.append(aug_map_patch)
                    rician_patches.append(aug_rician_patch)

    # 
    tes_values = {'tes': tes, 'count': len(patches)}

    return np.array(patches), np.array(mask_patches), np.array(map_patches), np.array(rician_patches), tes_values

#
def _bytes_feature(value):
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))

def _float_feature(value):
    return tf.train.Feature(float_list=tf.train.FloatList(value=value))

def _int64_feature(value):
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))

def serialize_example(image, mask, map_patch, rician_patch, tes, count):
    feature = {
        'image': _bytes_feature(image.tobytes()),
        'mask': _bytes_feature(mask.tobytes()),
        'map': _bytes_feature(map_patch.tobytes()),
        'rician': _bytes_feature(rician_patch.tobytes()),
        'tes': _float_feature(tes),
        'count': _int64_feature(count)
    }
    return tf.train.Example(features=tf.train.Features(feature=feature))

#
base_path = '/root/autodl-tmp/luqiqi_wuxiaofeng/data'
npy_file_paths = {
    'image': os.path.join(base_path, 'nf_norm', '2.npy'),
    'mask': os.path.join(base_path, 'mask', '2.npy'),
    'map': os.path.join(base_path, 'map', '2.npy'),
    'rician_norm': os.path.join(base_path, 'rician_norm', '2.npy'),
    'tes': os.path.join(base_path, 'tes', '2.npy')
}

try:
    image = np.load(npy_file_paths['image'])
    mask = np.load(npy_file_paths['mask'])
    map_data = np.load(npy_file_paths['map'])
    rician_norm = np.load(npy_file_paths['rician_norm'])
    tes = np.load(npy_file_paths['tes'])

    # 
    if image.shape[-1] == 1:
        image = np.squeeze(image, axis=-1)
    if image.ndim == 3 and image.shape[0] == 12:
        image = np.transpose(image, (1, 2, 0))

    if mask.shape[-1] == 1:
        mask = np.squeeze(mask, axis=-1)
    if mask.ndim == 3 and mask.shape[0] == 12:
        mask = np.transpose(mask, (1, 2, 0))
        mask = np.mean(mask, axis=-1)

    if map_data.shape[-1] == 1:
        map_data = np.squeeze(map_data, axis=-1)
    if map_data.ndim == 3 and map_data.shape[0] == 12:
        map_data = np.transpose(map_data, (1, 2, 0))

    if rician_norm.shape[-1] == 1:
        rician_norm = np.squeeze(rician_norm, axis=-1)
    if rician_norm.ndim == 3 and rician_norm.shape[0] == 12:
        rician_norm = np.transpose(rician_norm, (1, 2, 0))

    patch_size = 64
    stride = 16
    roi_threshold = 0.05
    aug_times = 3

    patches, mask_patches, map_patches, rician_patches, tes_info = extract_patches(
        image, mask, map_data, rician_norm, tes, patch_size, stride, roi_threshold, aug_times
    )

    print(f"Patches shape: {patches.shape}")
    print(f"Mask patches shape: {mask_patches.shape}")
    print(f"Map patches shape: {map_patches.shape}")
    print(f"Rician patches shape: {rician_patches.shape}")
    print(f"TES values: {tes_info}")

    print(f"Total extracted patches: {tes_info['count']}")

    # 
    tfrecord_path = os.path.join(base_path, 'patches.tfrecord')
    with tf.io.TFRecordWriter(tfrecord_path) as writer:
        for i in range(len(patches)):
            example = serialize_example(
                patches[i].astype(np.float32),
                mask_patches[i].astype(np.float32),
                map_patches[i].astype(np.float32),
                rician_patches[i].astype(np.float32),
                tes_info['tes'],
                tes_info['count']
            )
            writer.write(example.SerializeToString())

    print(f"TFRecord file saved at: {tfrecord_path}")

except Exception as e:
    print(f"Error: {e}")