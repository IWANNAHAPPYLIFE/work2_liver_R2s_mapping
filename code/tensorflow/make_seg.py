import numpy as np
import os
from PIL import Image


root_directory = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/seg_jpg'


output_directory = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/seg'


if not os.path.exists(output_directory):
    os.makedirs(output_directory)

#
subdirectories = [d for d in os.listdir(root_directory) if os.path.isdir(os.path.join(root_directory, d))]

# 
for subdir in subdirectories:
  
    subdir_path = os.path.join(root_directory, subdir)
    
   
    jpg_files = [f for f in os.listdir(subdir_path) if f.endswith('.jpg')]
    
    images = []

    #
    for file_name in jpg_files:
        file_path = os.path.join(subdir_path, file_name)
        
        with Image.open(file_path) as img:
         
            img_gray = img.convert('L')
            
            img_array = np.expand_dims(np.array(img_gray), axis=-1).astype(np.float32)
            
           
            if img_array.shape[:2] == (64, 128):  #
                images.append(img_array)
            else:
                print(f"Unexpected image size: {img_array.shape} for file {file_name}")

    #
    if len(images) == 1:
        #
        repeated_data = np.tile(images[0], (12, 1, 1, 1))
        
        output_path = os.path.join(output_directory, f'{subdir}.npy')
        np.save(output_path, repeated_data)
        
        print(f"Saved processed image to {output_path}")
        print("Final shape:", repeated_data.shape)
    else:
        print(f"Expected 1 image but found {len(images)} in {subdir}")