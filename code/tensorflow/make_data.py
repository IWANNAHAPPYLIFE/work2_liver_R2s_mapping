import os
import numpy as np
import tensorflow as tf

# 
def _bytes_feature(value):
    """Returns a bytes_list from a string / byte."""
    if isinstance(value, type(tf.constant(0))):
        value = value.numpy()  # BytesList won't unpack a string from an EagerTensor.
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))

def _float_feature(value):
    """Returns a float_list from a float / double."""
    return tf.train.Feature(float_list=tf.train.FloatList(value=[value]))

def _int64_feature(value):
    """Returns an int64_list from a bool / enum / int / uint."""
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))

def write2TFRecord_noise_free(img_gt,  map_gt, seg, tes, patient_ids, filename):
    filename = filename + '.tfrecords'
    print('Write to', filename)
    writer = tf.io.TFRecordWriter(filename)
    N, Nx, Ny, Nc = img_gt.shape
    _, _, _, Np = map_gt.shape

    for i in range(N):
        feature = {
            'img_gt': _bytes_feature(tf.io.serialize_tensor(img_gt[i])),
            'map_gt': _bytes_feature(tf.io.serialize_tensor(map_gt[i])),
            'seg': _bytes_feature(tf.io.serialize_tensor(seg[i])),
            'tes': _bytes_feature(tf.io.serialize_tensor(tes[i])),  # 使用实际的 tes 值
            'patient_id': _int64_feature(patient_ids[i]),  # 新增字段
            'Nx': _int64_feature(Nx),
            'Ny': _int64_feature(Ny),
            'Nc': _int64_feature(Nc),
            'Np': _int64_feature(Np),
        }
        example = tf.train.Example(features=tf.train.Features(feature=feature))
        writer.write(example.SerializeToString())
    writer.close()
    print('> Wrote', N, 'elements to TFRecord')

#
img_dir = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/train_val'
map_dir = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/map'
seg_dir = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/mask'
tes_dir = '/root/autodl-tmp/luqiqi_wuxiaofeng/data/tes'
# 
subdirs = sorted(os.listdir(img_dir))

# 
all_img = []
all_map = []
all_seg = []
all_tes = []

for subdir in subdirs:
    try:
        # 
        tes_path = os.path.join(tes_dir, subdir)
        img_path = os.path.join(img_dir, subdir)
        map_path = os.path.join(map_dir, subdir)
        seg_path = os.path.join(seg_dir, subdir)

        img = np.load(img_path)            # shape (12, 64, 128, 1)
        map_ = np.load(map_path)           # shape (12, 64, 128) -> reshape to (12, 64, 128, 1)
        seg = np.load(seg_path)            # shape (12, 64, 128, 1)
        tes = np.load(tes_path)            # 
        # print(tes.shape)
        print(img.shape)

        if map_.ndim == 3:
            map_ = np.expand_dims(map_, axis=-1)  # (12, 64, 128, 1)
            # print(map_.shape) #(12,64,128,1)

      
        if tes.ndim == 1:
            tes = tes.reshape(-1, 1)  # 
            # print(tes)

        all_img.append(img)
        all_map.append(map_)
        all_seg.append(seg)
        all_tes.append(tes)
    except Exception as e:
        print(f"[跳过] {subdir}: {e}")
        


if len(all_img) == 0:
    raise ValueError("没有成功加载任何数据，请检查文件路径和文件是否存在。")


img_all = np.concatenate(all_img, axis=0)  # (N, 64, 128, 1)
map_all = np.concatenate(all_map, axis=0)  # (N, 64, 128, 1)
seg_all = np.concatenate(all_seg, axis=0)  # (N, 64, 128, 1)
tes_all = np.concatenate(all_tes, axis=0)  # (N, 1)

print(img_all.shape)
print(map_all.shape)
print(seg_all.shape)
print(tes_all.shape)

patient_ids = []
for idx, img_sub in enumerate(all_img):
    num_samples = img_sub.shape[0]
    patient_ids.extend([idx] * num_samples)  # idx=0 ，idx=1 ...

patient_ids = np.array(patient_ids, dtype=np.int32)  # 

output_path = os.path.join('/root/autodl-tmp/luqiqi_wuxiaofeng/data', 'T2mapping', 'trainingdata', '45_te_0_sigma_mix')
os.makedirs(output_path, exist_ok=True)  # 
output_file = os.path.join(output_path, 'data_noise_free')


write2TFRecord_noise_free(img_all, map_all, seg_all, tes_all, patient_ids, output_file)