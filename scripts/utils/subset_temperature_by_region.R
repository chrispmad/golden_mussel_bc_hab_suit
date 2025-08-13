library(tidyverse)
library(terra)
library(sf)
library(stringr)


max_temps<-terra::rast("./data/monthly_tmax_average.nc")
names(max_temps)<-month.name


# Vectors of country (and province) names
asian_countries = c("China","Hong Kong","Japan","South Korea","Laos","Thailand","Taiwan")

south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

north_america = c("United States","BC")

whole_world = geodata::world(path = 'data')
plot(whole_world)
Canada<- whole_world[whole_world$NAME_0 == "Canada",]

country_lists <- list(
  "Asia" = asian_countries,
  "South_America" = south_american_countries,
  "North_America" = north_america
)


save_min_avg_temp_raster <- function(country_names, region_name) {
  for (country in country_names) {
    # Subset the country's geometry
    country_geom <- whole_world[whole_world$NAME_0 == country, ]
    
    # Check if the country exists in the shapefile
    if (nrow(country_geom) == 0) {
      warning(paste("Country not found in shapefile:", country))
      next
    }
    
    # Special handling for the United States
    if (country == "United States") {
      # Define the extent for the US
      usa_extent <- ext(-180, -50, 0, 71.3062515)
      
      # Crop the geometry to the custom extent
      country_geom <- terra::crop(country_geom, usa_extent)
      
      # Load and project BC geometry
      bc <- vect(bcmaps::bc_bound())
      bc <- project(bc, crs(country_geom))  # Ensure BC is in the same CRS as the US geometry
      
      # Combine BC with the US geometry
      country_geom <- terra::union(country_geom, bc)
    }
    
    # Mask and crop the raster
    country_raster <- terra::mask(terra::crop(max_temps, country_geom), country_geom)
    
    # Calculate the average temperature for each month
    avg_temps <- terra::global(country_raster, "mean", na.rm = TRUE)  # Global mean for each layer (month)
    
    # Find the month with the minimum average temperature
    min_month_idx <- which.max(avg_temps[, 1])  # Index of the month with the minimum average temp
    min_month_name <- names(country_raster)[min_month_idx]
    
    # Extract the raster for the month with the minimum temperature
    min_temp_raster <- country_raster[[min_month_idx]]
    names(min_temp_raster) <- min_month_name
    
    # Save the raster
    values(min_temp_raster) <- values(min_temp_raster) / 10
    country <- tolower(country)
    output_path <- file.path("./output_rasters", paste0(country, "_TMax_max_temp.tif"))
    dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
    terra::writeRaster(min_temp_raster, output_path, overwrite = TRUE)
    
    cat("Saved raster for:", country, "with minimum temperature in", min_month_name, "at", output_path, "\n")
  }
}


for (region_name in names(country_lists)) {
  save_min_avg_temp_raster(country_lists[[region_name]], region_name)
}

    