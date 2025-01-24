library(rinat)
library(tidyverse)
# library(DBI)
library(bcinvadeR)
library(terra)
library(sf)
library(geodata)
# library(predicts)
library(ggpubr)
# library(dismo)
# library(rJava)
library(ecospat)
library(ENMeval)
library(readxl)
library(ENMTools)
library(data.table)
library(ggplot2)

source("../ais_prioritization_models/scripts/utils/run_maxent_f.R")

# Set up file paths
lan_root = "//SFP.IDIR.BCGOV/S140/S40203/RSD_ FISH & AQUATIC HABITAT BRANCH/General/"
proj_wd = getwd()
onedrive_wd = paste0(str_extract(getwd(),"C:/Users/[A-Z]+/"),"OneDrive - Government of BC/data/")

# Grab occurrence records for Golden Mussel across the globe from iNaturalist.
gm_oc = rinat::get_inat_obs(taxon_name = "Limnoperna fortunei",maxresults = 10000)

# Convert table from iNaturalist query to a spatial table (sf object)
gm_sf = gm_oc |> 
  dplyr::rename(Species = common_name) |> 
  tidyr::as_tibble() |> 
  sf::st_as_sf(coords = c("longitude","latitude"), crs = 4326)


gmResearch<- gm_oc |> filter(quality_grade == "research") 

gmResearch <-gmResearch |> 
  mutate(observed_on = as.Date(observed_on, format = "%Y-%m-%d")) |> 
  mutate(year_observed = format(as.Date(observed_on, format = "%Y-%m-%d"), "%Y"))



ggplot(gmResearch, aes(x = year_observed)) +
  geom_bar(fill = "steelblue", color = "black") +
  labs(
    title = "Number of Observations by Year",
    x = "Year Observed",
    y = "Count of Observations"
  ) +
  theme_minimal()

# Vectors of country (and province) names
asian_countries = c("China","Hong Kong","Japan","South Korea","Laos","Thailand","Taiwan")

south_american_countries = c("Argentina","Brazil","Paraguay","Uruguay")

north_america = c("United States","BC")

gmResearch <- gmResearch |> 
  dplyr::rename(Species = common_name) |> 
  tidyr::as_tibble() |> 
  sf::st_as_sf(coords = c("longitude","latitude"), crs = 4326)


# Snag polygons for all countries in the world. For mapping purposes!
whole_world = geodata::world(path = 'data')

# Snag polygon for BC.
bc = bcmaps::bc_bound() |> dplyr::summarise() |> sf::st_transform(4326) |> terra::vect()

# Find which countries have at least one recorded Golden Mussel.
inf_countries = whole_world |> sf::st_as_sf() |> sf::st_make_valid() |> sf::st_filter(gmResearch) |> terra::vect()

inf_countries = sf::st_as_sf(inf_countries)
inf_countries[inf_countries$NAME_0 == 'United States',]$geometry = sf::st_crop(inf_countries[inf_countries$NAME_0 == 'United States',], 
                                                                               xmin = -180, xmax = -50, ymin = 0, ymax = 71.3062515) |> 
  dplyr::pull(geometry)
inf_countries = terra::vect(inf_countries)

asian_occs = gmResearch |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% asian_countries,])) |> 
  mutate(area = "Asia")
  
south_american_occs = gmResearch |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% south_american_countries,])) |> 
  mutate(area = "South America")

north_american_occs = gmResearch |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% north_america,])) |> 
  mutate(area = "North America")



gmOI<-do.call(rbind, list(asian_occs, south_american_occs, north_american_occs))

ggplot(gmOI, aes(x = year_observed, fill = area)) +
  geom_bar(
    position = position_dodge2(preserve = "single", padding = 0.1),
    width = 0.7,
    color = "black"
  ) +
  labs(
    title = "iNaturalist reports, by region and year",
    x = "Year Observed",
    y = "Count of Observations",
    fill = "Area"
  ) +
  theme_minimal() +
  scale_fill_viridis_d(option = "E")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

resolution <- 1  

points_extent <- st_bbox(gmOI) # bounding box


grid <- rast(ext(points_extent), resolution = resolution, crs = st_crs(gmOI)$wkt)


grid_polygons <- as.polygons(grid)
grid_sf <- st_as_sf(grid_polygons)
gmOI <- st_transform(gmOI, st_crs(grid_sf))
points_with_grid <- st_join(gmOI, grid_sf)
summary_data <- points_with_grid %>%
  group_by(id) %>%  # 'ID' is the grid cell identifier from the grid
  summarise(
    total_occurrences = n(),
    earliest_occurrence = min(as.Date(datetime, format = "%Y-%m-%d")),
    area = area
  )
grid_summary <- st_join(grid_sf, summary_data)

earliest<-grid_summary |> filter(total_occurrences > 0 )

earliest <- earliest |> 
  mutate(earliest_occurrence = as.Date(earliest_occurrence, format = "%Y-%m-%d")) |> 
  mutate(year_yearliest = format(as.Date(earliest_occurrence, format = "%Y-%m-%d"), "%Y"))
  

ggplot(earliest, aes(x = year_yearliest, fill = area)) +
  geom_bar(
    position = position_dodge2(preserve = "single", padding = 0.1),
    width = 0.7,
    color = "black"
  ) +
  labs(
    title = "iNaturalist reports, earliest occurrences",
    x = "Year Observed",
    y = "Count of Observations",
    fill = "Area"
  ) +
  theme_minimal() +
  scale_fill_viridis_d(option = "E")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
