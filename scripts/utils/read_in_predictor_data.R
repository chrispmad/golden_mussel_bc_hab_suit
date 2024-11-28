rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

# Vectors of country (and province) names
asian_countries = c("China","Hong Kong","Japan","South Korea","Laos","Thailand","Taiwan")

south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

north_america = c("United States","BC")

# Read in the rasters, by raster type, for all Asian countries.

# -----------------------------
# Asian Countries
# -----------------------------

asian_country_r = purrr::map(chosen_rasters, ~ {
  rasters = asian_countries |> 
    lapply(\(x) {
      x_for_filename = snakecase::to_snake_case(x)
      terra::rast(paste0(rast_filepath,x_for_filename,"_",.x,"_rast.tif"))
    })
  
  rasters_m <- do.call(terra::mosaic, c(rasters, list(fun = mean)))
  
  rasters_m
}, .progress = TRUE)

asian_country_r = terra::rast(asian_country_r)

# All Asian countries now combined!

# --------------------------
# South American Countries
# --------------------------

south_america_r = purrr::map(chosen_rasters, ~ {
  rasters = south_american_countries |> 
    lapply(\(x) {
      x_for_filename = snakecase::to_snake_case(x)
      terra::rast(paste0(rast_filepath,x_for_filename,"_",.x,"_rast.tif"))
    })
  
  rasters_m <- do.call(terra::mosaic, c(rasters, list(fun = mean)))
  
  rasters_m
}, .progress = TRUE)

south_america_r = terra::rast(south_america_r)
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

north_america_r = purrr::map(chosen_rasters, ~ {
  rasters = north_america |> 
    lapply(\(x) {
      x_for_filename = snakecase::to_snake_case(x)
      terra::rast(paste0(rast_filepath,x_for_filename,"_",.x,"_rast.tif"))
    })
  
  rasters_m <- do.call(terra::mosaic, c(rasters, list(fun = mean)))
  
  rasters_m
}, .progress = TRUE)

north_america_r = terra::rast(north_america_r)

invisible(gc())



