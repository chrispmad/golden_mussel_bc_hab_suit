library(rinat)
library(tidyverse)
# library(DBI)
library(bcinvadeR)
library(terra)
library(sf)
library(geodata)
# library(predicts)
library(ggpubr)
# library(dismo)
# library(rJava)
library(ecospat)
library(ENMeval)
library(readxl)
library(ENMTools)
library(data.table)

source("../ais_prioritization_models/scripts/utils/run_maxent_f.R")

# Set up file paths
lan_root = "//SFP.IDIR.BCGOV/S140/S40203/RSD_ FISH & AQUATIC HABITAT BRANCH/General/"
proj_wd = getwd()
onedrive_wd = paste0(str_extract(getwd(),"C:/Users/[A-Z]+/"),"OneDrive - Government of BC/data/")

# Grab occurrence records for Golden Mussel across the globe from iNaturalist.
gm_oc = rinat::get_inat_obs(taxon_name = "Limnoperna fortunei",maxresults = 10000)


# Convert table from iNaturalist query to a spatial table (sf object)
gm_sf = gm_oc |> 
  dplyr::rename(Species = common_name) |> 
  tidyr::as_tibble() |> 
  sf::st_as_sf(coords = c("longitude","latitude"), crs = 4326)

hydroclim = terra::rast("C:/Users/JPHELAN/Downloads/hydroclim_weighted_average+sum.nc")
#hydroclim = terra::rast(paste0(onedrive_wd,"raster/hydroclim.tif"))

# Snag polygons for all countries in the world. For mapping purposes!
whole_world = geodata::world(path = 'data')
Canada<- whole_world[whole_world$NAME_0 == "Canada",]

# Snag polygon for BC.
#bc = bcmaps::bc_bound() |> dplyr::summarise() |> sf::st_transform(4326) |> terra::vect()


# Find which countries have at least one recorded Golden Mussel.
inf_countries = whole_world |> sf::st_as_sf() |> sf::st_make_valid() |> sf::st_filter(gm_sf) |> terra::vect()
crs(Canada)<-crs(inf_countries)
names(hydroclim)[1]<-"Annual Mean Upstream Temperature"
hydroclim_list<-list()

crs(inf_countries)<-crs(hydroclim)
for (i in 1:length(inf_countries[inf_countries$NAME_0!="United States",])) {
  hydroclim_list[[i]] = terra::mask(terra::crop(hydroclim[[1]], inf_countries[i,]), inf_countries[i,])
  plot(hydroclim_list[[i]])
  #print(inf_countries[i,]$NAME_0)
}
names(hydroclim_list)<-inf_countries[inf_countries$NAME_0!="United States",]$NAME_0

hydroclim_list[["United States"]] = terra::mask(terra::crop(hydroclim[[1]], inf_countries[inf_countries$NAME_0 == "United States",]),
                                                inf_countries[inf_countries$NAME_0 == "United States",])
hydroclim_list[["United States"]]= terra::crop(hydroclim_list[["United States"]], c(-180,-50, 18, 72))
crs(Canada)<-crs(hydroclim[[1]])
hydroclim_list[["Canada"]]<-terra::mask(terra::crop(hydroclim[[1]], Canada), Canada)

plot(hydroclim_list[["United States"]])
plot(hydroclim_list[["Canada"]])

setGDALconfig("GDAL_PAM_ENABLED", "FALSE")
for (i in 1:length(hydroclim_list)){
  terra::writeRaster(hydroclim_list[[i]], paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",inf_countries[i,]$NAME_0,"_annual_weight_mean_temp.tif"),
                     overwrite = TRUE)
}