
select_temp_rast<-function(region_names) {
  
  region_names<-tolower(region_names)
  region_names<-gsub(" ", "_", region_names)
  combined_rasters <- purrr::map(region_names, function(region_name) {
    select_temp_rast <- list.files(
      path = paste0(onedrive_wd, "raster/hydroclim_goldMussel_rast/"),
      pattern = paste0(region_name, "_Min.monthlyairtemperaturefor[[:alpha:]]+"),
      full.names = TRUE
    )
    
    
    temp_rasts <- terra::rast(select_temp_rast)
    
    
    layer_min_values <- global(temp_rasts, fun = "min", na.rm = TRUE)$min
    layer_max_values <- global(temp_rasts, fun = "max", na.rm = TRUE)$max
    min_layer <- which.min(layer_min_values)
    max_layer <- which.max(layer_max_values)
    min_temp_layer <- temp_rasts[[min_layer]]
    max_temp_layer <- temp_rasts[[max_layer]]
    names(min_temp_layer)<-"Min_air_temp_month"
    min_temp_layer
  })
  
  
  final_combined_raster <- do.call(terra::mosaic, c(combined_rasters, list(fun = mean)))
  
  return(final_combined_raster)
}

