
import os
import numpy as np
import tensorflow as tf

# ---------------- --------------
def data_aug(img_patch, mask_patch, rician_patch, s0_patch, r2_patch, mode):
    if mode == 1:
        return np.fliplr(img_patch), np.fliplr(mask_patch), np.fliplr(rician_patch), np.fliplr(s0_patch), np.fliplr(r2_patch)
    elif mode == 2:
        return np.flipud(img_patch), np.flipud(mask_patch), np.flipud(rician_patch), np.flipud(s0_patch), np.flipud(r2_patch)
    elif mode == 3:
        return np.rot90(img_patch, 2), np.rot90(mask_patch, 2), np.rot90(rician_patch, 2), np.rot90(s0_patch, 2), np.rot90(r2_patch, 2)
    else:
        return img_patch, mask_patch, rician_patch, s0_patch, r2_patch

# ----------------  ----------------
def extract_patches(image, mask, rician, s0_map, r2_map, tes,
                    patch_size=64, stride=16, roi_threshold=0.05, aug_times=1):
    patches, mask_patches, rician_patches, s0_patches, r2_patches, tes_list = [], [], [], [], [], []

    num_echoes, h, w = image.shape
    for i in range(0, h - patch_size + 1, stride):
        for j in range(0, w - patch_size + 1, stride):
            img_patch = image[:, i:i+patch_size, j:j+patch_size]          # [12, 64, 64]
            rician_patch = rician[:, i:i+patch_size, j:j+patch_size]      # [12, 64, 64]
            mask_patch = mask[0, i:i+patch_size, j:j+patch_size]          # [64, 64]
            s0_patch = s0_map[i:i+patch_size, j:j+patch_size]             # [64, 64]
            r2_patch = r2_map[i:i+patch_size, j:j+patch_size]             # [64, 64]

            if np.mean(mask_patch) > roi_threshold:
                for mode in range(aug_times + 1):
                    img_aug = np.stack([
                        data_aug(img_patch[k], mask_patch, rician_patch[k], s0_patch, r2_patch, mode)[0]
                        for k in range(num_echoes)
                    ], axis=-1)  # [64, 64, 12]

                    rician_aug = np.stack([
                        data_aug(img_patch[k], mask_patch, rician_patch[k], s0_patch, r2_patch, mode)[2]
                        for k in range(num_echoes)
                    ], axis=-1)  # [64, 64, 12]

                    # 
                    s0_aug = data_aug(img_patch[0], mask_patch, rician_patch[0], s0_patch, r2_patch, mode)[3]  # [64, 64]
                    r2_aug = data_aug(img_patch[0], mask_patch, rician_patch[0], s0_patch, r2_patch, mode)[4]  # [64, 64]

                    mask_aug = data_aug(img_patch[0], mask_patch, rician_patch[0], s0_patch, r2_patch, mode)[1]  # [64, 64]

                    patches.append(img_aug.astype(np.float32))              # [64, 64, 12]
                    rician_patches.append(rician_aug.astype(np.float32))   # [64, 64, 12]
                    s0_patches.append(s0_aug[..., np.newaxis].astype(np.float32))  # [64, 64, 1]
                    r2_patches.append(r2_aug[..., np.newaxis].astype(np.float32))  # [64, 64, 1]
                    mask_patches.append(mask_aug[..., np.newaxis].astype(np.float32))  # [64, 64, 1]
                    tes_list.append(tes.astype(np.float32))                # [12]

    return (np.array(patches), np.array(mask_patches), np.array(rician_patches),
            np.array(s0_patches), np.array(r2_patches), np.array(tes_list))


# --------------------
def _bytes_feature(value):
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[tf.io.serialize_tensor(value).numpy()]))

def _int64_feature(value):
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))

def write2TFRecord_multi(img_gt, s0_gt, r2_gt, seg, rician, tes, filename):
    writer = tf.io.TFRecordWriter(filename)
    N, Nx, Ny, Nc = img_gt.shape
    _, _, _, Np = s0_gt.shape
    for i in range(N):
        feature = {
            'img_gt': _bytes_feature(img_gt[i]),
            's0_gt': _bytes_feature(s0_gt[i]),
            'r2_gt': _bytes_feature(r2_gt[i]),
            'seg': _bytes_feature(seg[i]),
            'rician': _bytes_feature(rician[i]),
            'tes': _bytes_feature(tes[i]),
            'Nx': _int64_feature(Nx),
            'Ny': _int64_feature(Ny),
            'Nc': _int64_feature(Nc),
            'Np': _int64_feature(Np)
        }
        example = tf.train.Example(features=tf.train.Features(feature=feature))
        writer.write(example.SerializeToString())
    writer.close()
    print(f'> TFRecord saved: {filename} with {img_gt.shape[0]} samples')

# -----------------------------
def main():
    base_path = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/valid'
    file_list = sorted([f.split('.')[0] for f in os.listdir(os.path.join(base_path, 'img')) if f.endswith('.npy')])

    all_patches = []
    all_masks = []
    all_ricians = []
    all_s0s = []
    all_r2s = []
    all_tes = []

    for file_id in file_list:
        print(f'Processing: {file_id}')
        image = np.load(os.path.join(base_path, 'img_norm', f'{file_id}.npy'))         # [12, H, W, 1]
        mask = np.load(os.path.join(base_path, 'mask', f'{file_id}.npy'))         # [12, H, W, 1]
        rician = np.load(os.path.join(base_path, 'rician_norm', f'{file_id}.npy'))# [12, H, W, 1]
        map_s0 = np.load(os.path.join(base_path, 'map_s0', f'{file_id}.npy'))  # [H, W]
        map_r2 = np.load(os.path.join(base_path, 'map_r2', f'{file_id}.npy'))  # [H, W]
        
        tes = np.load(os.path.join(base_path, 'tes', f'{file_id}.npy'))           # [12]

        image = np.squeeze(image, axis=-1)      # 
        mask = np.squeeze(mask, axis=-1)        # 
        rician = np.squeeze(rician, axis=-1)    # 
        # map_s0 = np.squeeze(map_s0, axis=-1)      #
        # map_r2 = np.squeeze(map_r2, axis=-1)  
        # map_s0=map_s0.transpose((2, 0, 1))
        # map_r2=map_r2.transpose((2, 0, 1))
        # print(map_s0.shape)

        patches, masks, ricians, s0s, r2s, tes_list = extract_patches(
            image=image,
            mask=mask,
            rician=rician,
            s0_map=map_s0,
            r2_map=map_r2,
            tes=tes,
            patch_size=64,
            stride=16,
            roi_threshold=0.05,
            aug_times=1
        )

        if patches.size > 0:
            all_patches.append(patches)
            all_masks.append(masks)
            all_ricians.append(ricians)
            all_s0s.append(s0s)
            all_r2s.append(r2s)
            all_tes.append(tes_list)

    all_patches = np.concatenate(all_patches, axis=0)
    all_masks = np.concatenate(all_masks, axis=0)
    all_ricians = np.concatenate(all_ricians, axis=0)
    all_s0s = np.concatenate(all_s0s, axis=0)
    all_r2s = np.concatenate(all_r2s, axis=0)
    all_tes = np.concatenate(all_tes, axis=0)

    print('patch shape:', all_patches.shape)  # (patches_num, 64, 64, 12)
    print('mask shape:', all_masks.shape)  # (patches_num, 64, 64, 1)
    print('s0 shape:', all_s0s.shape)  # (patches_num, 64, 64, 1)
    print('r2 shape:', all_r2s.shape)  # (patches_num, 64, 64, 1)
    print('tes shape:', all_tes.shape)  # (patches_num, 12)

    tfrecord_path = os.path.join(base_path, 'validdata.tfrecords')
    write2TFRecord_multi(all_patches, all_s0s, all_r2s, all_masks, all_ricians, all_tes, tfrecord_path)

if __name__ == "__main__":
    main()
