import numpy as np
import os

# 
root_directory = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/train_map'

# 
output_directory = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/train_map_map'

# 
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# 
subdirectories = [d for d in os.listdir(root_directory) if os.path.isdir(os.path.join(root_directory, d))]

for subdir in subdirectories:
   
    subdir_path = os.path.join(root_directory, subdir)
    
  
    npy_files = [f for f in os.listdir(subdir_path) if f.endswith('.npy')]
    
    
    images = []
    
    
    for file_name in npy_files:
      
        file_path = os.path.join(subdir_path, file_name)
        
       
        npy_data = np.load(file_path)
        
    
        if npy_data.shape == (64, 128):
            
            npy_data = npy_data.astype(np.float32)
            images.append(npy_data)
        else:
            print(f"Unexpected image size: {npy_data.shape} for file {file_name}")
    
    #
    if len(images) == 1:
        #
        repeated_data = np.tile(images[0], (12, 1, 1))
        
        output_path = os.path.join(output_directory, f'{subdir}.npy')
        np.save(output_path, repeated_data)
        
        print(f"Saved processed image to {output_path}")
        print("Final shape:", repeated_data.shape)
    else:
        print(f"Expected 1 image but found {len(images)} in {subdir}")