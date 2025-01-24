
select_max_min_temp_rast<-function(countries) {
  
  countries<-tolower(countries)
  
  combined_rasters <- purrr::map(countries, function(country) {
    select_temp_rast <- list.files(
      path = paste0(onedrive_wd, "raster/hydroclim_goldMussel_rast/"),
      pattern = paste0(country, "_TMax_max_temp.tif"),
      full.names = TRUE
    )
    
    
    temp_rasts <- terra::rast(select_temp_rast)
    temp_rasts
  })
  
  
  if(length(combined_rasters) >1){
  final_combined_raster <- do.call(terra::mosaic, c(combined_rasters, list(fun = mean)))
  }else{
    final_combined_raster <- combined_rasters[[1]]
  }
  
  return(final_combined_raster)
}
