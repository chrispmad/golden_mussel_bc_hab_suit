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

# Read in the hydroclimatic variables downloaded from https://www.earthenv.org/
# hydroclim = terra::rast("data/hydroclim_average+sum.nc")
# Once we've cropped and masked this to infected countries, just read that 
# file in!
hydroclim = terra::rast(paste0(onedrive_wd,"raster/hydroclim.tif"))

# These are the variables that are contained in this file.

# hydro_*_01 = Annual Mean Upstream Temperature
# hydro_*_02 = Mean Upstream Diurnal Range (Mean of monthly (max temp - min temp))
# hydro_*_03 = Upstream Isothermality (hydro_02 / hydro_07) (* 100)
# hydro_*_04 = Upstream Temperature Seasonality (standard deviation *100)
# hydro_*_05 = Maximum Upstream Temperature of Warmest Month
# hydro_*_06 = Minimum Upstream Temperature of Coldest Month
# hydro_*_07 = Upstream Temperature Annual Range (hydro_05 - hydro_06)
# hydro_*_08 = Mean Upstream Temperature of Wettest Quarter
# hydro_*_09 = Mean Upstream Temperature of Driest Quarter
# hydro_*_10 = Mean Upstream Temperature of Warmest Quarter
# hydro_*_11 = Mean Upstream Temperature of Coldest Quarter
# hydro_*_12 = Annual Upstream Precipitation
# hydro_*_13 = Upstream Precipitation of Wettest Month
# hydro_*_14 = Upstream Precipitation of Driest Month
# hydro_*_15 = Upstream Precipitation Seasonality (Coefficient of Variation)
# hydro_*_16 = Upstream Precipitation of Wettest Quarter
# hydro_*_17 = Upstream Precipitation of Driest Quarter
# hydro_*_18 = Upstream Precipitation of Warmest Quarter
# hydro_*_19 = Upstream Precipitation of Coldest Quarter

# # Water chemistry variables from Appendix 3 of 
# # "Global Groundwater Solute Composition and Concentrations - Wood - 2022 - Groundwater - Wiley Online Library"
# # link: https://ngwa.onlinelibrary.wiley.com/doi/full/10.1111/gwat.13205
# water_chem = readxl::read_excel("data/gwat13205-sup-0003-supinfo03.xlsx", skip = 3)
# 
# # For now, let's trim water chemistry variables to Ca, Mg, Na, Temp C, and Dissolved Oxyen.
# water_chem_choice = water_chem |> 
#   dplyr::select(Latitude:Ca)
#   #dplyr::select(Latitude:Na,`Dissolved oxygen`,pH,`Temp C`)
# 
# # Here are counts of how many rows of non-NA data we have for each of the 
# # selected variables; this info may prompt us to cut out relatively data-sparse 
# # variables like Dissolved oxygen.
# water_chem_choice |> dplyr::reframe(dplyr::across(-c(Latitude,Longitude), \(x) sum(!is.na(x))))
# 
# # Make sure we have something for all variables for each coordinate.
# water_chem_choice = water_chem_choice[complete.cases(water_chem_choice),]
# 
# water_chem_sf = sf::st_as_sf(water_chem_choice, coords = c("Longitude","Latitude"), crs = 4326)

# Snag polygons for all countries in the world. For mapping purposes!
whole_world = geodata::world(path = 'data')


# Snag polygon for BC.
bc = bcmaps::bc_bound() |> dplyr::summarise() |> sf::st_transform(4326) |> terra::vect()

ggplot() + 
  tidyterra::geom_spatvector(data = whole_world) + 
  tidyterra::geom_spatvector(data = bc, fill = 'purple') + 
  geom_sf(data = gm_sf, col = 'red')

# Oh no! Bad data coverage for water chemistry variables!! Bah.

# Find which countries have at least one recorded Golden Mussel.
inf_countries = whole_world |> sf::st_as_sf() |> sf::st_make_valid() |> sf::st_filter(gm_sf) |> terra::vect()

# Mask and crop the hydroclim data with these countries
# hydroclim_m = terra::mask(terra::crop(hydroclim, inf_countries), inf_countries)

# 1. Simplify the raster?
# 2. Do we 'do' each country separately, to use smaller rasters?
# 3. Just straight into MaxEnt?

# avg_mean_temp = hydroclim[[1]]
# avg_mean_temp[is.na(avg_mean_temp)]
# 
# terra::plot(hydroclim[[1]])
# 
# usa_hydroclim = terra::crop(hydroclim[[1]], inf_countries[inf_countries$NAME_0 %in% c("United States"),])
# 
# usa_hydroclim_just_usa = terra::crop(usa_hydroclim, c(-180,-50, 18, 72))
# 
# usa_pseudos = predicts::backgroundSample(usa_hydroclim_just_usa, 
#                            p = terra::vect(gm_sf), 
#                            n = 10000,
#                            extf = 0.9) |> 
#   tidyr::as_tibble()
# 
# names(usa_pseudos) = c('lon','lat')
# 
# ggplot() + 
#   tidyterra::geom_spatraster(data = usa_hydroclim_just_usa) + 
#   geom_sf(data = sf::st_as_sf(usa_pseudos, coords = c('lon','lat'), crs = 4326))
# 
# terra::plot(usa_pseudos, add = T)
# nrow(usa_pseudos)
# 
# usa_pseudos

pseudoabsences <- predicts::backgroundSample(hydroclim[[1]], 
                                             p = terra::vect(gm_sf), 
                                             n = 10000,
                                             extf = 0.9) |> 
  as.data.frame()

am_i_mortal = ENMevaluate(occs = gm_oc |> dplyr::select(latitude, longitude),
            envs = hydroclim[[1]],
            # bg = pseudoabsences,
            n.bg = 10000,
            algorithm = 'maxent.jar',
            partitions = 'block',
            tune.args = list(fc = 'LQ',
                             rm = c(3)))
