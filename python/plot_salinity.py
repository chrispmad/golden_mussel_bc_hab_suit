#%%
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from netCDF4 import Dataset
import numpy as np

#%%
#open nc file
file_path = "../data/salinity/IOS_CTD_Profiles_fef0_8ece_7627.nc"
file_id = nc.Dataset(file_path)
# Print the metadata for the "Power" variable
print(file_id)
#print(file_id.variables['sea_water_practical_salinity'])
# %%
# pring the meta data as a dict
#print(file_id.__dict__)  
file_id.variables.keys()

# %%
for dimension in file_id.dimensions.values():
  print(dimension)
# %%
# variables OI "latitude", "longitude", "time", "depth", sea water temperature, "sea_water_practical_salinity"
lat = file_id['latitude'][:]
lon = file_id['longitude'][:]
time = file_id['time'][:]
depth = file_id['depth'][:]
sal = file_id['sea_water_practical_salinity'][:]
# %%
fig = plt.figure(figsize=(12, 8))
ax = plt.axes(projection=ccrs.PlateCarree())  # Use Plate Carree projection
ax.coastlines(resolution="110m", linewidth=1)
#ax.add_feature(cfeature.BORDERS, linewidth=0.5)
ax.add_feature(cfeature.LAND, edgecolor='black')
ax.add_feature(cfeature.LAKES, edgecolor='black', facecolor='lightblue')
ax.add_feature(cfeature.RIVERS, edgecolor='blue')
# Plot the salinity data
# Assuming salinity values align with lat/lon dimensions
sc = plt.scatter(lon, lat, c=sal, cmap="viridis", s=10, transform=ccrs.PlateCarree())
plt.colorbar(sc, label="Sea Water Practical Salinity")
# Add title and labels
plt.title("Salinity - Salish Sea", fontsize=14)
ax.set_xlabel("Longitude")
ax.set_ylabel("Latitude")
# Set extent (optional, adjust based on your data)
ax.set_extent([lon.min() - 1, lon.max() + 1, lat.min() - 1, lat.max() + 1], crs=ccrs.PlateCarree())
# Show the plot
plt.savefig("../images/salinity_all.png")
# %%
