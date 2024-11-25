rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

# Vectors of country (and province) names
asian_countries = c("China","Hong Kong","Japan","South Korea","Laos","Thailand","Taiwan")

south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

north_america = c("United States","BC")

# Read in the rasters, by raster type, for all Asian countries.

# -----------------------------
# Asian Countries
# -----------------------------

# 1. Annual mean temperature
asian_country_temps_r = asian_countries |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[1],"_rast.tif"))
  })

asian_country_temps_merged <- do.call(terra::mosaic, c(asian_country_temps_r, list(fun = mean)))

# terra::plot(asian_country_temps_merged)

# 1. Max temp of warmest month
asian_country_max_warmest_r = asian_countries |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[2],"_rast.tif"))
  })

asian_country_max_warmest_merged <- do.call(terra::mosaic, c(asian_country_max_warmest_r, list(fun = mean)))

# terra::plot(asian_country_max_warmest_merged)

# Combine the rasters.
asian_country_r = c(asian_country_temps_merged, asian_country_max_warmest_merged)

# All Asian countries now combined!

# --------------------------
# South American Countries
# --------------------------

# 1. Annual mean temperature
south_american_country_temps_r = south_american_countries |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[1],"_rast.tif"))
  })

south_american_country_temps_merged <- do.call(terra::mosaic, c(south_american_country_temps_r, list(fun = mean)))

# terra::plot(south_american_country_temps_merged)

# 1. Max temp of warmest month
south_american_country_max_warmest_r = south_american_countries |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[2],"_rast.tif"))
  })

south_american_country_max_warmest_merged <- do.call(terra::mosaic, c(south_american_country_max_warmest_r, list(fun = mean)))

# terra::plot(south_american_country_max_warmest_merged)

# Combine the rasters.
south_american_country_r = c(south_american_country_temps_merged, south_american_country_max_warmest_merged)

# All south_american countries now combined!

# --------------------------
# North American Countries / Provinces
# --------------------------

# 1. Annual mean temperature
north_american_country_temps_r = north_america |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[1],"_rast.tif"))
  })

north_american_country_temps_merged <- do.call(terra::mosaic, c(north_american_country_temps_r, list(fun = mean)))

# terra::plot(north_american_country_temps_merged)

# 1. Max temp of warmest month
north_american_country_max_warmest_r = north_america |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[2],"_rast.tif"))
  })

north_american_country_max_warmest_merged <- do.call(terra::mosaic, c(north_american_country_max_warmest_r, list(fun = mean)))

# terra::plot(north_american_country_max_warmest_merged)

# Combine the rasters.
north_american_country_r = c(north_american_country_temps_merged, north_american_country_max_warmest_merged)

# All north_american bits now combined!
