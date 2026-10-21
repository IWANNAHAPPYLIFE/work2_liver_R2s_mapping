import tensorflow as tf
import os
import functions as func
import scipy.io as sio
import numpy as np
import gzip
import struct
import cv2
import functions_data as func_data
import tensorflow as tf
import numpy as np
import os
import functions as func
def load_training_data(file_name, id_tau, rescale_para, type_task, signed=True):
    """
    Load dataset from TFRecords, split train/valid, and compute max values for maps_gt channels.
    Returns:
        dataset_train, dataset_valid, dataset_train_size, dataset_valid_size, max_ch0, max_ch1
    """
    dataset_filenames = tf.io.gfile.glob(file_name)
    dataset = tf.data.TFRecordDataset(dataset_filenames)\
                .map(func.parse_all)\
                .map(lambda x1,x2,x3,x4,x5,x6,x7: func.extract(
                    x1,x2,x3,x4,x5,x6,x7,
                    id_tau=id_tau,
                    rescale=rescale_para,
                    model_type='unrolling',
                    data_type='mono',
                    task=type_task,
                    signed=signed))

    # split the data for training and validation
    split = 0.9
    dataset_size = func.get_len(dataset)
    dataset_train_size = int(dataset_size*split)
    dataset_valid_size = dataset_size - dataset_train_size

    # validation data
    dataset_valid = dataset.shard(num_shards=5, index=4)
    # training data
    dataset_train = dataset.shard(num_shards=5, index=0)
    # for i in [1,2,3]:
    #     dataset_train = dataset_train.concatenate(dataset.shard(num_shards=5, index=i))

    print('-'*98)
    print('Dataset')
    print(dataset_filenames)
    print('  Training data size : {}'.format(dataset_train_size))
    print('Validation data size : {}'.format(dataset_valid_size))
    return dataset_train, dataset_valid, dataset_train_size, dataset_valid_size


def load_data(train_file, val_file, id_tau, rescale_para, type_task, signed=True):
    """
    Load dataset from train/val TFRecords (already split), return datasets and sizes
    """
 
    dataset_train = tf.data.TFRecordDataset(train_file) \
        .map(func.parse_all) \
        .map(lambda x1,x2,x3,x4,x5,x6,x7: func.extract(
            x1,x2,x3,x4,x5,x6,x7,
            id_tau=id_tau,
            rescale=rescale_para,
            model_type='unrolling',
            data_type='mono',
            task=type_task,
            signed=signed))
    dataset_train_size = func.get_len(dataset_train)


    dataset_valid = tf.data.TFRecordDataset(val_file) \
        .map(func.parse_all) \
        .map(lambda x1,x2,x3,x4,x5,x6,x7: func.extract(
            x1,x2,x3,x4,x5,x6,x7,
            id_tau=id_tau,
            rescale=rescale_para,
            model_type='unrolling',
            data_type='mono',
            task=type_task,
            signed=signed))
    dataset_valid_size = func.get_len(dataset_valid)

    print('-'*98)
    print('Dataset')
    print(f'  Training data size : {dataset_train_size}')
    print(f'Validation data size : {dataset_valid_size}')

    return dataset_train, dataset_valid, dataset_train_size, dataset_valid_size

def load_test_data(file_name, id_tau, rescale_para, type_task, signed=True):
    dataset_filenames = tf.io.gfile.glob(file_name)
    dataset = tf.data.TFRecordDataset(dataset_filenames)\
                .map(func.parse_all)\
                .map(lambda x1,x2,x3,x4,x5,x6,x7: func.extract(
                    x1,x2,x3,x4,x5,x6,x7,
                    id_tau=id_tau,
                    rescale=rescale_para,
                    model_type='unrolling',
                    data_type='mono',
                    task=type_task,
                    signed=signed
                ))
    
    dataset_size = func.get_len(dataset)
    print('-'*98)
    print('Test Dataset')
    print(dataset_filenames)
    print('  Test data size : {}'.format(dataset_size))
    print('-'*98)

    return dataset, dataset_size


def load_test_size(file_name, id_tau, rescale_para, type_task, signed=True):
    dataset_filenames = tf.io.gfile.glob(file_name)
    dataset = tf.data.TFRecordDataset(dataset_filenames) \
        .map(func.parse_all) \
        .map(lambda x1, x2, x3, x4, x5, x6, x7:
             func.extract(x1, x2, x3, x4, x5, x6, x7,
                          id_tau=id_tau,
                          rescale=rescale_para,
                          model_type='unrolling',
                          data_type='mono',
                          task=type_task,
                          signed=signed))

    dataset_size = func.get_len(dataset)

    print('-' * 98)
    print('Dataset')
    print(dataset_filenames)
    print('  test data size : {}'.format(dataset_size))
    print('-' * 98)

    return dataset   # 




def load_invivo_data(dir_data,rescale,tau_test,rescale_img=1.0):
    imgs_n_raw = sio.loadmat(os.path.join(dir_data,'image.mat'))['data'] # [999,128,128]
    tau_raw    = sio.loadmat(os.path.join(dir_data,'TIs.mat'))['TIs']    # [999,1] ms
    # ------------------------------------------------------------------------------
    # pre-processing
    imgs_n = np.transpose(imgs_n_raw,axes=(1,2,0))[np.newaxis] # [1,128,128,999]
    tau = np.squeeze(tau_raw,axis=-1)[np.newaxis] # ms
    # ------------------------------------------------------------------------------
    # extract tau and data used for testing.
    id_tau = np.array([np.where(np.abs(tau[0]-x)<0.001)[0][0] for x in tau_test])
    imgs_n = imgs_n[...,id_tau]
    tau = tau[...,id_tau]
    # ------------------------------------------------------------------------------
    # rescale and resize
    imgs_n = func_data.resize_wimg(imgs_n,scale_factor=3)*rescale_img
    tau = np.repeat(tau,imgs_n.shape[0],axis=0)/rescale # ms/400
    # ------------------------------------------------------------------------------
    print('-'*98)
    print('Test datasets  :')
    print('Test file name :',dir_data)
    print('Imgs           :',str(imgs_n.shape))
    print('TEs            :',str(tau.shape),str(tau[0]*rescale))
    return imgs_n,tau

def save_to(dir_results,name_model,data):
    if os.path.exists(os.path.join(dir_results,name_model)) == False: 
        os.mkdir(os.path.join(dir_results,name_model))
    np.save(os.path.join(dir_results,name_model,'maps_pred.npy'),data)

def npy_to_raw(data,dir_data):
    '''
    - data, [Ny,Nx,Nc]
    - dir_data, `dir_data`.raw. 
    '''
    output = np.transpose(data,axes=(2,0,1))
    output.astype('float64').tofile(dir_data+'.raw')

def read_binary(file_name,data_type='uint8',shape=None):
    """
    Read suppressed binary file to image with shape of `shape`.
    ### ARGUMENT
    - file_name, raw data file file name.
    - data_type, data type.
    - shape, image shape.
    
    ### RETURN
    - data, image data with shape of `shape`.

    ### USE
    read_binary(file_name=path,data_type='int8',shape=shape)
    """
    dic = {'uint8':'B','int8':'b'}
    assert data_type in list(dic.keys()), 'Unsupported data type. Only for '+str(list(dic.keys()))
    size = 1
    for i in range(len(shape)): size=size*shape[i]
    suffix = os.path.splitext(file_name)[-1]
    if suffix == '.gz': 
        with gzip.open(file_name,'rb') as file: data = file.read()
    if suffix == '.raw': 
        with open(file_name,'rb') as file: data = file.read()
    data = struct.unpack(dic[data_type]*size,data)
    data = np.reshape(data,shape)
    return data

def rescale_wimg(img,percent=99):
    '''
    Rescale image using percentiles.
    '''
    scale = np.percentile(img[...,0],percent)
    img_rescale = img/scale
    return(img_rescale)

def resize_wimg(img,scale_factor=2.0):
    '''image interpolation.
    '''
    op_interpolation_2d = lambda x: cv2.resize(x,None,fx=scale_factor,fy=scale_factor,\
                                            interpolation=cv2.INTER_LINEAR)
    Ndim = len(img.shape)
    N,Ny,Nx,Nc = img.shape
    if Ndim == 4:
        img_resize = []
        for i in range(N):
            tmp = []
            for j in range(Nc):
                tmp.append(op_interpolation_2d(img[i,...,j]))
            img_resize.append(tmp)
        img_resize = np.transpose(np.stack(img_resize),axes=(0,2,3,1))
    if Ndim == 3:
        img_resize = []
        for i in range(Nc):
            img_resize.append(op_interpolation_2d(img[...,i]))
        img_resize = np.transpose(np.stack(img_resize),axes=(1,2,0))
    if Ndim == 2:
        img_resize = op_interpolation_2d(img)
    return img_resize