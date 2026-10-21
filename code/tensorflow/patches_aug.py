import numpy as np
import matplotlib.pyplot as plt
import os

def data_aug(patch, mask_patch, map_patch, rician_patch, mode):
    
    if mode == 1: #
        return np.fliplr(patch), np.fliplr(mask_patch), np.fliplr(map_patch), np.fliplr(rician_patch)
    elif mode == 2: # 
        return np.flipud(patch), np.flipud(mask_patch), np.flipud(map_patch), np.flipud(rician_patch)
    elif mode == 3: # 
        return np.rot90(patch, 2), np.rot90(mask_patch, 2), np.rot90(map_patch, 2), np.rot90(rician_patch, 2)
    else:
        return patch, mask_patch, map_patch, rician_patch

def extract_patches(image, mask, map_data, rician_norm, tes, patch_size=64, stride=16, roi_threshold=0.1, aug_times=3):
    
    h, w, c = image.shape
    patches, mask_patches, map_patches, rician_patches, tes_values = [], [], [], [], []
    
    for i in range(0, h - patch_size + 1, stride):
        for j in range(0, w - patch_size + 1, stride):
            
            patch = image[i:i + patch_size, j:j + patch_size, :]
            mask_patch = mask[i:i + patch_size, j:j + patch_size]
            map_patch = map_data[i:i + patch_size, j:j + patch_size, :]
            rician_patch = rician_norm[i:i + patch_size, j:j + patch_size, :]
            
           
            if np.mean(mask_patch) > roi_threshold:
               
                patches.append(patch); mask_patches.append(mask_patch); map_patches.append(map_patch); rician_patches.append(rician_patch); tes_values.append(tes)
                
             
                for mode in range(1, aug_times + 1): #
                    aug_patch, aug_mask_patch, aug_map_patch, aug_rician_patch = data_aug(patch, mask_patch, map_patch, rician_patch, mode)
                    patches.append(aug_patch); mask_patches.append(aug_mask_patch); map_patches.append(aug_map_patch); rician_patches.append(aug_rician_patch); tes_values.append(tes)

    return np.array(patches), np.array(mask_patches), np.array(map_patches), np.array(rician_patches), tes_values


base_path = '/root/autodl-tmp/luqiqi_wuxiaofeng/data'
npy_file_paths = {
    'image': os.path.join(base_path, 'nf_norm', '2.npy'),
    'mask': os.path.join(base_path, 'mask', '2.npy'),
    'map': os.path.join(base_path, 'map', '2.npy'),
    'rician_norm': os.path.join(base_path, 'rician_norm', '2.npy'),
    'tes': os.path.join(base_path, 'tes', '2.npy')
}

#
try:
    
    image = np.load(npy_file_paths['image'])
    mask = np.load(npy_file_paths['mask'])
    map_data = np.load(npy_file_paths['map'])
    rician_norm = np.load(npy_file_paths['rician_norm'])
    tes = np.load(npy_file_paths['tes'])

    print(f"Loaded image shape: {image.shape}")
    print(f"Loaded mask shape: {mask.shape}")
    print(f"Loaded map shape: {map_data.shape}")
    print(f"Loaded rician_norm shape: {rician_norm.shape}")
    print(f"Loaded tes shape: {tes.shape}")

   
    if image.shape[-1] == 1:
        image = np.squeeze(image, axis=-1)
        print(f"Image shape after removing redundant channel: {image.shape}")
    if image.ndim == 3 and image.shape[0] == 12:
        image = np.transpose(image, (1, 2, 0))
        print(f"Image shape after transposing: {image.shape}")

    #
    if mask.shape[-1] == 1:
        mask = np.squeeze(mask, axis=-1)
        print(f"Mask shape after removing redundant channel: {mask.shape}")
    if mask.ndim == 3 and mask.shape[0] == 12:
        mask = np.transpose(mask, (1, 2, 0))
        mask = np.mean(mask, axis=-1)
        print(f"Mask shape after transposing and averaging: {mask.shape}")

    # 
    if map_data.shape[-1] == 1:
        map_data = np.squeeze(map_data, axis=-1)
        print(f"Map shape after removing redundant channel: {map_data.shape}")
    if map_data.ndim == 3 and map_data.shape[0] == 12:
        map_data = np.transpose(map_data, (1, 2, 0))
        print(f"Map shape after transposing: {map_data.shape}")

    # 
    if rician_norm.shape[-1] == 1:
        rician_norm = np.squeeze(rician_norm, axis=-1)
        print(f"Rician_norm shape after removing redundant channel: {rician_norm.shape}")
    if rician_norm.ndim == 3 and rician_norm.shape[0] == 12:
        rician_norm = np.transpose(rician_norm, (1, 2, 0))
        print(f"Rician_norm shape after transposing: {rician_norm.shape}")

    #
    patch_size = 64
    stride = 16
    roi_threshold = 0.05  #
    aug_times = 3  #
    patches, mask_patches, map_patches, rician_patches, tes_values = extract_patches(
        image, mask, map_data, rician_norm, tes, patch_size=patch_size, stride=stride, roi_threshold=roi_threshold, aug_times=aug_times
    )

    
    print(f"Extracted {len(patches)} patches of size {patch_size}x{patch_size} with stride {stride}.")

    # 
    if len(patches) == 0:
        print("No patches extracted. Check the image dimensions, patch size, and ROI threshold.")
    else:
        
        num_patches = len(patches)
        fig, axes = plt.subplots(4, num_patches, figsize=(20, 10))
        
        for i in range(num_patches):
           
            axes[0, i].imshow(patches[i, :, :, 0], cmap='gray')
            axes[0, i].axis('off')
            axes[0, i].set_title(f'Patch {i+1}')
           
            axes[1, i].imshow(mask_patches[i], cmap='gray')
            axes[1, i].axis('off')
            axes[1, i].set_title(f'Mask {i+1}')
            #
            axes[2, i].imshow(map_patches[i, :, :, 0], cmap='gray')
            axes[2, i].axis('off')
            axes[2, i].set_title(f'Map {i+1}')
            
            axes[3, i].imshow(rician_patches[i, :, :, 0], cmap='gray')
            axes[3, i].axis('off')
            axes[3, i].set_title(f'Rician {i+1}')
            # axes[3, i].set_title(f'Rician Norm {i+1}\nTES: {tes_values[i]}')
        
        plt.show()

except Exception as e:
    print(f"Error loading the .npy file: {e}")