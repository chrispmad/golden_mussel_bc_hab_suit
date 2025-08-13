rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

north_america = c("United States","BC")

# -----------------------------
# North America
# -----------------------------

north_america_r = purrr::map(chosen_rasters, ~ {
  rasters = north_america |> 
    lapply(\(x) {
      x_for_filename = snakecase::to_snake_case(x)
      terra::rast(paste0(rast_filepath,x_for_filename,"_",.x,"_rast.tif"))
    })
  
  rasters_m <- do.call(terra::mosaic, c(rasters, list(fun = mean)))
  
  rasters_m
})

north_america_r = terra::rast(north_america_r)