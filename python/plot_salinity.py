#%%
from zipfile import ZipFile
from collections import defaultdict
file_name = "../data/salinity/LTTSGP_1999_2023.zip"

#read in excel files
with ZipFile(file_name, 'r') as zip:
    zip.printdir
    
    file_names = zip.namelist()
    files = {name: zip.read(name) for name in zip.namelist()}
# %%
# merge the above dicts to make on large one
for key, value in files.items():
    print(key, value)

# %%
