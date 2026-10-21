import os
import shutil

def remove_ipynb_checkpoints(root_path):
  
    # os.walk() 
    for folder_path, dir_names, file_names in os.walk(root_path):
        for dir_name in dir_names:
            if dir_name == ".ipynb_checkpoints":
                full_dir_path = os.path.join(folder_path, dir_name)
                print(f"Removing: {full_dir_path}")
                try:
                    shutil.rmtree(full_dir_path)
                except Exception as e:
                    print(f"Error removing {full_dir_path}: {e}")

    print("Finished removing all .ipynb_checkpoints directories.")

# 
root_path = "/root/autodl-tmp/data"

# 
remove_ipynb_checkpoints(root_path)