rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

# Vectors of country (and province) names
asian_countries = c("China","Hong Kong","Japan","South Korea","Laos","Thailand","Taiwan")

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
