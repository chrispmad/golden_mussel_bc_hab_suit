rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

north_america = c("United States","BC")


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
# 3. add slope 
north_american_slope <- north_america |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[3],"_rast.tif"))
  })
north_american_slope_merged <- do.call(terra::mosaic, c(north_american_slope, list(fun = mean)))

# 4. Read in clay data
north_american_clay <- north_america |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[4], "_rast.tif"))
  })
north_american_country_clay_merged <- do.call(terra::mosaic, c(north_american_clay, list(fun = mean)))

# 5. Read in silt data
north_american_silt <- north_america |>  # Replace "asian_countries" with "north_american_countries"
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[5], "_rast.tif"))
  })
north_american_country_silt_merged <- do.call(terra::mosaic, c(north_american_silt, list(fun = mean)))

# 6. Read in sand data (similar changes)
north_american_sand <- north_america |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[6], "_rast.tif"))
  })
north_american_country_sand_merged <- do.call(terra::mosaic, c(north_american_sand, list(fun = mean)))

# 7. Read in carbon data (similar changes)
north_american_carbon <- north_america |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[7], "_rast.tif"))
  })
north_american_country_carbon_merged <- do.call(terra::mosaic, c(north_american_carbon, list(fun = mean)))

# 8. Read in pH data (similar changes)
north_american_pH <- north_america |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[8], "_rast.tif"))
  })
north_american_country_pH_merged <- do.call(terra::mosaic, c(north_american_pH, list(fun = mean)))

# Combine the rasters.
north_american_country_r = c(north_american_country_temps_merged, north_american_country_max_warmest_merged, north_american_slope_merged,
                             north_american_country_clay_merged, north_american_country_silt_merged, north_american_country_sand_merged, north_american_country_carbon_merged,
                             north_american_country_pH_merged)

rm(north_american_country_temps_merged, north_american_country_max_warmest_merged, north_american_slope_merged,
   north_american_country_clay_merged, north_american_country_silt_merged, north_american_country_sand_merged, north_american_country_carbon_merged,
   north_american_country_pH_merged, north_american_pH, north_american_carbon, north_american_sand,
   north_american_silt, north_american_clay, north_american_slope)
# All north_american bits now combined!

invisible(gc())

