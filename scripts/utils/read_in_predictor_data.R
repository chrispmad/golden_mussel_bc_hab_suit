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

# 2. Max temp of warmest month
asian_country_max_warmest_r = asian_countries |> 
  lapply(\(x) {
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[2],"_rast.tif"))
  })

asian_country_max_warmest_merged <- do.call(terra::mosaic, c(asian_country_max_warmest_r, list(fun = mean)))

# terra::plot(asian_country_max_warmest_merged)

# 3. Read in slope
asian_slope <- asian_countries |> 
  lapply(\(x) { 
         x_for_filename = snakecase::to_snake_case(x)
        terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[3],"_rast.tif"))
                 })
asian_country_slope_merged <- do.call(terra::mosaic, c(asian_slope, list(fun = mean)))

# 4. Read in clay data
asian_clay <- asian_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[4],"_rast.tif"))
  })
asian_country_clay_merged <- do.call(terra::mosaic, c(asian_clay, list(fun = mean)))

# 5. Read in silt data
asian_silt <- asian_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[5],"_rast.tif"))
  })
asian_country_silt_merged <- do.call(terra::mosaic, c(asian_silt, list(fun = mean)))

# 6. Read in sand data
asian_sand <- asian_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[6],"_rast.tif"))
  })
asian_country_sand_merged <- do.call(terra::mosaic, c(asian_sand, list(fun = mean)))

# 7. Read in carbon data
asian_carbon <- asian_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[7],"_rast.tif"))
  })
asian_country_carbon_merged <- do.call(terra::mosaic, c(asian_carbon, list(fun = mean)))

# 8. Read in silt data
asian_pH <- asian_countries |> 
  lapply(\(x) { 
    x_for_filename = snakecase::to_snake_case(x)
    terra::rast(paste0(rast_filepath,x_for_filename,"_",chosen_rasters[8],"_rast.tif"))
  })
asian_country_pH_merged <- do.call(terra::mosaic, c(asian_pH, list(fun = mean)))


# Combine the rasters.
asian_country_r = c(asian_country_temps_merged, asian_country_max_warmest_merged, asian_country_slope_merged,
                    asian_country_clay_merged, asian_country_silt_merged, asian_country_sand_merged, asian_country_carbon_merged,
                    asian_country_pH_merged)

rm(asian_country_temps_merged, asian_country_max_warmest_merged, asian_country_slope_merged,
   asian_country_clay_merged, asian_country_silt_merged, asian_country_sand_merged, asian_country_carbon_merged,
   asian_country_pH_merged, asian_sand, asian_silt, asian_slope, asian_clay, asian_carbon, asian_pH)


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
   south_american_country_pH_merged, south_american_slope, south_american_pH, south_american_carbon,
   south_american_sand, south_american_silt, south_american_clay)
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

# All north_american bits now combined!

rm(north_american_country_temps_merged, north_american_country_max_warmest_merged, north_american_slope_merged,
   north_american_country_clay_merged, north_american_country_silt_merged, north_american_country_sand_merged, north_american_country_carbon_merged,
   north_american_country_pH_merged, north_american_pH, north_american_carbon, north_american_sand,
   north_american_silt, north_american_clay, north_american_slope)

invisible(gc())



