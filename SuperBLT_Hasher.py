#Python implementation of the SuperBLT hashing library
#v1.0
# Original Code by fragtrane, https://github.com/fragtrane/Python-SuperBLT-Hash-Calculator

import hashlib
import os
import sys

#Calculate SHA-256
def SuperBLT_Hash(input_data, directory, BLOCKSIZE = 8192):
    hasher = hashlib.sha256()
    if directory:
        with open(input_data, 'rb') as file:
            buf = file.read(BLOCKSIZE)
            while len(buf) > 0:
                hasher.update(buf)
                buf = file.read(BLOCKSIZE)
    else:
        hasher.update(input_data)
    return hasher.hexdigest()

#Hash file, hash hash
def SuperBLT_Hash_File(file_path):
    hashed = SuperBLT_Hash(file_path, True)
    return SuperBLT_Hash(hashed.encode(), False)

#Hash files, join hashes (ordered by unicode value of directories), hash joined hashes
def SuperBLT_Hash_Dir(input_directory):
    hashes = dict()
    for root, dirs, files in os.walk(input_directory, topdown=True):
        dirs[:] = [d for d in dirs if d != ".git"]
        for file in files:
            file_path = os.path.join(root, file)
            hashes[file_path.lower().encode('utf-8')] = SuperBLT_Hash(file_path, True)
    sorted_keys = sorted(hashes.keys())
    joined_hash = ""
    for key in sorted_keys:
        joined_hash = joined_hash + hashes[key]
    return SuperBLT_Hash(joined_hash.encode(), False)


#Print BLT-Hash of path, given as start-arg
path = sys.argv[1]
if os.path.isfile(path):
    print(SuperBLT_Hash_File(path))
else:
    print(SuperBLT_Hash_Dir(path))
    