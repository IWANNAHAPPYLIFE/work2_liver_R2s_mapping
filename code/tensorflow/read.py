import pydicom
import numpy as np

# 
# file_path = '/root/autodl-tmp/img_gt/2/MR033001001.dcm'


# ds = pydicom.dcmread(file_path)


# img = ds.pixel_array


# print("Image shape:", img.shape)


# file_path = '/root/autodl-tmp/luqiqi/data/map/2.npy'

data = np.load(file_path)
import os
import numpy as np


data_folder = '/autodl-tmp/data/train_img'


for filename in os.listdir(data_folder):
    if filename.endswith('.npy'):
        file_path = os.path.join(data_folder, filename)

        data = np.load(file_path)
 
        print(f"文件: {filename}")
        print(f"shape: {data.shape}")

        if len(data.shape) == 3:
            print("→ 单通道图像 (shape: x, y, z)\n")
        elif len(data.shape) == 4:
            print(f"→ 多通道图像 (shape: x, y, z, c)，共 {data.shape[-1]} 个通道\n")
        else:
            print("→ 其他维度结构，需进一步查看\n")


print("Data shape:", data.shape)
