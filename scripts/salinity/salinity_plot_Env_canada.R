library(openxlsx)
library(tidyverse)
library(data.table)
library(sf)
library(terra)
library(RColorBrewer)
library(ggspatial)
library(tidyterra)

sal_data<- list.files(path="./data/salinity/LTTSGP_1999_2023/", pattern ="\\.csv", full.name = T) 

# Assuming sal_data is a character vector of file paths
data_list <- map(sal_data, ~read.csv(., header = TRUE, fileEncoding = "UTF-8")) 


data_comb<-rbindlist(data_list, fill = T)
names(data_comb)<-c("Ship", "date", "lon", "lat", "depth", "temp.temp", "temperature",
                    "salinity") 

sal_data<-data_comb|> 
  select(date, lon, lat, depth, temperature, salinity) |> 
  mutate(temperature = as.numeric(temperature, salinity = as.numeric(salinity)))

sal_data_avg <- sal_data %>%
  mutate(
    temperature = as.numeric(temperature), 
    salinity = as.numeric(salinity) 
  ) %>% 
  group_by(lon, lat, depth) %>% 
  summarize(
    mean_temperature = mean(temperature),
    mean_salinity = mean(salinity)
  )
  

sal_data_sf <- st_as_sf(sal_data_avg, coords = c("lon", "lat"), crs = 4326) 
ext <- ext(sal_data_sf) # Get extent from the data
res <- 0.1 # Adjust resolution as needed (e.g., 0.1 degrees)
rast_template <- rast(ext, res = res)
salinity_raster <- rasterize(sal_data_sf, rast_template, field = "mean_salinity", fun = mean)

bc<-bcmaps::bc_bound()

salinity_df <- as.data.frame(salinity_raster, xy = TRUE)
colnames(salinity_df) <- c("x", "y", "salinity")
bc_df <- st_as_sf(bc) %>% 
  ggplot2::fortify()

ggplot() +
  geom_spatraster(data = salinity_raster, aes(fill = mean)) + # Plot raster directly
  scale_fill_viridis_c(name = "Salinity", na.value = "transparent") + # Color scale
  geom_sf(data = bc, fill = NA, color = "black", size = 0.5) + # Overlay BC boundary
  coord_sf() +
  theme_minimal() +
  labs(title = "Salinity Raster with BC Boundary",
       x = "Longitude",
       y = "Latitude")


library(rnaturalearth)
canada <- rnaturalearth::ne_countries(scale = "medium", country = "Canada", returnclass = "sf")
ggplot() +
  geom_sf(data = canada, fill = "lightblue", color = "black", size = 0.5) +
  theme_minimal() +
  labs(
    title = "Base Map of Canada",
    x = "Longitude",
    y = "Latitude"
  ) +
  coord_sf()
salinity_raster <- terra::project(salinity_raster, crs(canada))

ggplot() +
  geom_spatraster(data = salinity_raster, aes(fill = mean)) + # Add the salinity raster
  scale_fill_viridis_c(name = "Salinity", na.value = "transparent") +  # Color scale for raster
  geom_sf(data = canada, fill = NA, color = "black", size = 0.5) +     # Overlay Canada boundary
  coord_sf() +
  theme_minimal() +
  labs(
    title = "Salinity Raster with Canada Basemap",
    x = "Longitude",
    y = "Latitude"
  )
