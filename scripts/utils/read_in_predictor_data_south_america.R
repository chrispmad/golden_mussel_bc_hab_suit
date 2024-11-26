rast_filepath = paste0(onedrive_wd,"raster/hydroclim_goldMussel_rast/")

# Vectors of country (and province) names
south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

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
# 3. read in slope
south_american_slope <- south_american_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[3],"_rast.tif"))
  })
south_american_slope_merged <- do.call(terra::mosaic, c(south_american_slope, list(fun = mean)))

# 4. Read in clay data
south_american_clay <- south_american_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[4],"_rast.tif"))
  })
south_american_country_clay_merged <- do.call(terra::mosaic, c(south_american_clay, list(fun = mean)))

# 5. Read in silt data
south_american_silt <- south_american_countries |>  # Replace "asian_countries" with "south_american_countries"
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[5], "_rast.tif"))
  })
south_american_country_silt_merged <- do.call(terra::mosaic, c(south_american_silt, list(fun = mean)))

# 6. Read in sand data (similar changes)
south_american_sand <- south_american_countries |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[6], "_rast.tif"))
  })
south_american_country_sand_merged <- do.call(terra::mosaic, c(south_american_sand, list(fun = mean)))

# 7. Read in carbon data (similar changes)
south_american_carbon <- south_american_countries |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[7], "_rast.tif"))
  })
south_american_country_carbon_merged <- do.call(terra::mosaic, c(south_american_carbon, list(fun = mean)))

# 8. Read in pH data (similar changes)
south_american_pH <- south_american_countries |>
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath, x_for_filename, "_", chosen_rasters[8], "_rast.tif"))
  })
south_american_country_pH_merged <- do.call(terra::mosaic, c(south_american_pH, list(fun = mean)))

# Combine the rasters.
south_american_country_r = c(south_american_country_temps_merged, south_american_country_max_warmest_merged, south_american_slope_merged,
                             south_american_country_clay_merged, south_american_country_silt_merged, south_american_country_sand_merged, south_american_country_carbon_merged,
                             south_american_country_pH_merged)

rm(south_american_country_temps_merged, south_american_country_max_warmest_merged, south_american_slope_merged,
   south_american_country_clay_merged, south_american_country_silt_merged, south_american_country_sand_merged, south_american_country_carbon_merged,
   south_american_country_pH_merged)
