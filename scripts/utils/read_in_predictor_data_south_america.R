rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

# Vectors of country (and province) names
south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

# -----------------------------
# South America
# -----------------------------

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