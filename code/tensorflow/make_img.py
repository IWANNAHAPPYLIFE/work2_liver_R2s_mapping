import pydicom
import numpy as np
import os

# 
root_directory = '/root/autodl-tmp/'

# 
output_directory = '/root/autodl-tmp/'

# 
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

#
subdirectories = [d for d in os.listdir(root_directory) if os.path.isdir(os.path.join(root_directory, d))]


for subdir in subdirectories:
    # 
    subdir_path = os.path.join(root_directory, subdir)
    
    # 
    dicom_files = sorted([f for f in os.listdir(subdir_path) if f.endswith('.dcm')])
    
    # 
    images = []
    tes_times = []
    
    # 
    for file_name in dicom_files:
        # 
        file_path = os.path.join(subdir_path, file_name)
        
        # 
        print(f"Processing file: {file_name}")
        
        # 
        ds = pydicom.dcmread(file_path)
        
        # 
        img = ds.pixel_array.astype(np.float32)  # 
        img = np.expand_dims(img, axis=-1)  # 
        
        # 
        tes_time = ds.get('EchoTime', None)  # 
        
        # 
        if tes_time is None:
            print(f"Echo Time not found in file: {file_name}")
            tes_time = 0  #
        else:
            print(f"Echo Time found: {tes_time} for file: {file_name}")
        
        # 
        if img.shape == (64, 128, 1):
            images.append(img)
            tes_times.append(tes_time)
        else:
            print(f"Unexpected image size: {img.shape} for file {file_name}")
    
    # 
    if len(images) == 12:
        images_np = np.array(images)  # (12, 64, 128, 1)
        tes_times_np = np.array(tes_times)  # (12,)
        
        # 
        images_output_path = os.path.join(output_directory, f'{subdir}.npy')
        np.save(images_output_path, images_np)
        print(f"Saved images to {images_output_path}")
        
        # # 
        # tes_times_output_path = os.path.join(output_directory, f'{subdir}.npy')
        # np.save(tes_times_output_path, tes_times_np)
        # print(f"Saved tes times to {tes_times_output_path}")
        
        print("Final shapes:", images_np.shape, ", tes times shape:", tes_times_np.shape)
    else:
        print(f"Expected 12 images but found {len(images)} in {subdir}")