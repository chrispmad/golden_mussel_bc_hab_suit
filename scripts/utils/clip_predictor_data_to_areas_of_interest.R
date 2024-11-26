
# Snag polygons for all countries in the world. For mapping purposes!
whole_world = geodata::world(path = 'data')

# Snag polygon for BC.
bc = bcmaps::bc_bound() |> dplyr::summarise() |> sf::st_transform(4326) |> terra::vect()

# Find which countries have at least one recorded Golden Mussel.
inf_countries = whole_world |> sf::st_as_sf() |> sf::st_make_valid() |> sf::st_filter(gm_sf) |> terra::vect()

# Note: we have to correct the USA extent to basically not cover the entire world!
inf_countries = sf::st_as_sf(inf_countries)
inf_countries[inf_countries$NAME_0 == 'United States',]$geometry = sf::st_crop(inf_countries[inf_countries$NAME_0 == 'United States',], 
                                                                               xmin = -180, xmax = -50, ymin = 0, ymax = 71.3062515) |> 
  dplyr::pull(geometry)
inf_countries = terra::vect(inf_countries)

# Ensure both spatial objects have the same CRS.
inf_countries = terra::project(inf_countries, terra::crs("GEOGCRS[\"unknown\",\n    DATUM[\"unnamed\",\n        ELLIPSOID[\"Spheroid\",6378137,298.257223563,\n            LENGTHUNIT[\"metre\",1,\n                ID[\"EPSG\",9001]]]],\n    PRIMEM[\"Greenwich\",0,\n        ANGLEUNIT[\"degree\",0.0174532925199433,\n            ID[\"EPSG\",9122]]],\n    CS[ellipsoidal,2],\n        AXIS[\"latitude\",north,\n            ORDER[1],\n            ANGLEUNIT[\"degree\",0.0174532925199433,\n                ID[\"EPSG\",9122]]],\n        AXIS[\"longitude\",east,\n            ORDER[2],\n            ANGLEUNIT[\"degree\",0.0174532925199433,\n                ID[\"EPSG\",9122]]]]"))
bc = terra::project(bc, terra::crs(inf_countries))

# Read in the metadata from Earth Env for Hydroclim variables, soil variables, etc.
ncInfo<-read.table("./other/nc_info.txt",sep = "|", header = TRUE, stringsAsFactors = FALSE)
ncInfo$Unit <- gsub("\\[|\\]", "", ncInfo$Unit)  # Remove brackets from units
ncInfo<-ncInfo[, -(ncol(ncInfo))]
ncInfo<-ncInfo[,-1]
ncInfo = tidyr::as_tibble(ncInfo)


# Read in the hydroclimatic variables downloaded from https://www.earthenv.org/
# hydroclim = terra::rast("data/hydroclim_average+sum.nc")
# Once we've cropped and masked this to infected countries, just read that 
# file in!
if(reclip_hydroclim){
  hydroclim_all = terra::rast(paste0(onedrive_wd,"../../Downloads/hydroclim_average+sum.nc"))
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
  
  # These are the variables that are contained in this file. We are going to 
  # just use the annual mean temperature, maximum temp of warmest month (lakes that 
  # go above 15-18 degrees C at any point in the year are flagged as potential habitat
  # for Golden Mussels.)
  
  hydroclim = hydroclim_all[[c(1,5)]]
  names(hydroclim) = c("annual_mean_temp", "max_temp_warmest_month")
  
  # This lapply loop trims each raster layer for each of the 
  # infected countries, saving those to the onedrive raster data folder, in a 
  c(inf_countries$NAME_0,'BC') |> 
    lapply(\(x) {
      print(paste0("Working on termperature for ",x))
      the_country = inf_countries[inf_countries$NAME_0 == x,]
      # It's not a country... but let's pop BC in here, if that's the name we're coding for.
      if(x == 'BC') the_country = bc
      country_e = ext(the_country)
      x_for_filename = snakecase::to_snake_case(x)
      # Crop the rasters in turn.
      for(rast_type in names(hydroclim)){
        # Check to see if this file has been made already. If not, make it!
        if(!file.exists(paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))){
          the_country_r = terra::mask(terra::crop(hydroclim[[rast_type]], country_e), the_country)
          terra::writeRaster(x = the_country_r, paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))
        }
      }
    })
  
  rm(hydroclim); rm(hydroclim_all)
  invisible(gc())
}

if(reclip_slope){
  slope_all = terra::rast(paste0(onedrive_wd,"/raster/slope.nc"))
  
  # 4 layers here - min, max, rage, average
  
  
  # These are the variables that are contained in this file. We are going to 
  # just use the annual mean temperature, maximum temp of warmest month (lakes that 
  # go above 15-18 degrees C at any point in the year are flagged as potential habitat
  # for Golden Mussels.)
  
  slope_average = slope_all[[4]]
  names(slope_average) = "slope_average"
  
  # This lapply loop trims each raster layer for each of the 
  # infected countries, saving those to the onedrive raster data folder, in a 
  c(inf_countries$NAME_0,'BC') |> 
    lapply(\(x) {
      print(paste0("Working on slope for ",x))
      the_country = inf_countries[inf_countries$NAME_0 == x,]
      # It's not a country... but let's pop BC in here, if that's the name we're coding for.
      if(x == 'BC') the_country = bc
      country_e = ext(the_country)
      x_for_filename = snakecase::to_snake_case(x)
      # Crop the rasters in turn.
      for(rast_type in names(slope_average)){
        # Check to see if this file has been made already. If not, make it!
        if(!file.exists(paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))){
          the_country_r = terra::mask(terra::crop(slope_average[[rast_type]], country_e), the_country)
          terra::writeRaster(x = the_country_r, paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))
        }
      }
    })
  
  rm(slope_average); rm(slope_all)
  invisible(gc())
}

if(reclip_soil){
  soil_all = terra::rast(paste0(onedrive_wd,"raster/soil_average.nc"))
  
  # 4 layers here - min, max, rage, average
  
  
  # These are the variables that are contained in this file. We are going to 
  # just use the annual mean temperature, maximum temp of warmest month (lakes that 
  # go above 15-18 degrees C at any point in the year are flagged as potential habitat
  # for Golden Mussels.)
  match_idx <- which(grepl("soil_average.nc", ncInfo[,"netCDF.file...Variable.name"]))
  if (length(match_idx) == 0) {
    warning("No match found for the provided string")
  }
  
  
  names(soil_all) <- gsub("_+$", "", gsub(" ", "_", ncInfo[match_idx, "Variable.explanation"]))
  
  soil_all<-soil_all[[c(1:5)]]
  # This lapply loop trims each raster layer for each of the 
  # infected countries, saving those to the onedrive raster data folder, in a 
  c(inf_countries$NAME_0,'BC') |> 
    lapply(\(x) {
      print(paste0("Working on soil average for ",x))
      the_country = inf_countries[inf_countries$NAME_0 == x,]
      # It's not a country... but let's pop BC in here, if that's the name we're coding for.
      if(x == 'BC') the_country = bc
      country_e = ext(the_country)
      x_for_filename = snakecase::to_snake_case(x)
      # Crop the rasters in turn.
      for(rast_type in names(soil_all)){
        # Check to see if this file has been made already. If not, make it!
        if(!file.exists(paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))){
          the_country_r = terra::mask(terra::crop(soil_all[[rast_type]], country_e), the_country)
          terra::writeRaster(x = the_country_r, paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/",x_for_filename,"_",rast_type,"_rast.tif"))
        }
      }
    })
  
  rm(soil_all); 
  invisible(gc())
}












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

# pseudoabsences <- predicts::backgroundSample(hydroclim[[1]], 
#                                              p = terra::vect(gm_sf), 
#                                              n = 10000,
#                                              extf = 0.9) |> 
#   as.data.frame()

# #hydroclim_small<-aggregate(hydroclim, fact = 8)
# target_resolution <- res(hydroclim) * 5
# target_raster <- rast(nrows = nrow(hydroclim) / 10, ncols = ncol(hydroclim) / 10, 
#                       ext = ext(hydroclim), crs = crs(hydroclim), resolution = target_resolution)
# hydroclim_small <- resample(hydroclim, target_raster)
# 
# plot(hydroclim_small)
# 
# terra::writeRaster(hydroclim_small, paste0(onedrive_wd,"raster/hydroclim_reduced.tif"))
# 
# plot(hydroclim_small)
# hydroclim_small[[1]]


