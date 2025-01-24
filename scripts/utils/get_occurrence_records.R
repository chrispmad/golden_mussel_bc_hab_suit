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

gm_oc <- gm_oc |> filter(quality_grade == "research") 
# Convert table from iNaturalist query to a spatial table (sf object)
gm_sf = gm_oc |> 
  dplyr::rename(Species = common_name) |> 
  tidyr::as_tibble() |> 
  sf::st_as_sf(coords = c("longitude","latitude"), crs = 4326)


occs<-read.table("./data/occurrences.txt", sep = "\t", header = T)

occs<-occs |> 
  rename(lat = Latitude, lon = Longitude, notes = Nota, species = Especie, 
         presence = Presenca) |> 
  mutate(date = paste0(Ano,"-",Mes,"-",Dia)) |> 
  mutate(date = as.Date(date, format = "%Y-%B-%d"))

occs<-st_as_sf(occs, coords = c("lon","lat"))
occs <- occs |> st_set_crs(4326)
occs<-st_transform(occs, crs = st_crs(gm_sf))


# plot(st_geometry(occs))
# whole_world = geodata::world(path = 'data')
# lines(whole_world, add = T)

gm_sf <- st_join(gm_sf, occs)


