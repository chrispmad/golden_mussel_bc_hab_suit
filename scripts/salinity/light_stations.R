library(sf)
library(bcdata)
library(bcmaps)
library(ggplot2)
library(readr)
library(data.table)
library(dplyr)
library(stringr)
library(tidyr)
library(zoo)
library(RColorBrewer)

bc<-bc_bound()
#locations of the lightstations
lightstations<-st_read("./data/salinity/BC_lightstation/BC_Lighthouse_DATA.shp")

#plot(st_geometry(lightstations))

ggplot() +
  geom_sf(data=bc, color = "lightgrey")+
  geom_sf(data=lightstations, color = "black", fill = "black")


salinity_files<-list.files(path = "./data/salinity/BC_lightstation/Data_Active_Sites_20240620/",
                           pattern = "*.csv", full.names = T)
salinity_readings<-lapply(salinity_files, read_csv)

sal1<-salinity_readings[[1]]
colnames(sal1)[1]
col_names<-sal1[1,]

#gsub(":","",unique(word(colnames(x)[1], end = pmin(str_count(sentences, "\\w+"), 3))))

#get the first cell, where the names of the lightstations are stored and name the list item
#this - remove the : at the end of the word
names(salinity_readings)<-lapply(salinity_readings, function(x) 
  gsub(":","",unique(word(colnames(x)[1], end = pmin(str_count(sentences, "\\w+"), 3)))))

names(salinity_readings)
year_range = seq(from = 2000, to = 2024, by = 1)

salinity_readings<-lapply(salinity_readings, function(x){
  names(x)<- as.character(unlist(x[1,]))
  x<-x[-1,]
  return(x)
})

salinity_readings<-lapply(salinity_readings, function(x){
  x<-pivot_longer(x, !YEAR, names_to = "month", values_to = "value")
  x <- x |> 
    mutate(YEAR = as.numeric(YEAR), value = as.numeric(value)) |> 
    subset(YEAR > 1999) |> 
    mutate(year_month = as.Date(paste(YEAR, month, "1", sep = "-"), format = "%Y-%b-%d")) |> 
    subset(value < 50)
  return(x)
})
  
salinity_readings<-bind_rows(salinity_readings, .id = "lighthouse")

ggplot() +
  geom_line(data = salinity_readings, aes(x = year_month, y = value, color = lighthouse)) +
  scale_color_viridis_d(option = "turbo") + # Option: "viridis", "plasma", "cividis", etc.
  facet_wrap(. ~ lighthouse)+
  theme_light()


salinity_files_inactive<-list.files(path = "./data/salinity/BC_lightstation/DATA_Inactive_Site/",
                           pattern = "*.csv", full.names = T)
salinity_readings_inactive<-lapply(salinity_files_inactive, read_csv)


sal1<-salinity_readings_inactive[[1]]
colnames(sal1)[1]
col_names<-sal1[1,]

#gsub(":","",unique(word(colnames(x)[1], end = pmin(str_count(sentences, "\\w+"), 3))))

#get the first cell, where the names of the lightstations are stored and name the list item
#this - remove the : at the end of the word
names(salinity_readings_inactive)<-lapply(salinity_readings_inactive, function(x) 
  gsub(":","",unique(word(colnames(x)[1], end = pmin(str_count(sentences, "\\w+"), 3)))))

names(salinity_readings_inactive)
#year_range = seq(from = 2000, to = 2024, by = 1)

salinity_readings_inactive<-lapply(salinity_readings_inactive, function(x){
  names(x)<- as.character(unlist(x[1,]))
  x<-x[-1,]
  return(x)
})

salinity_readings_inactive<-lapply(salinity_readings_inactive, function(x){
  x<-pivot_longer(x, !YEAR, names_to = "month", values_to = "value")
  x <- x |> 
    mutate(YEAR = as.numeric(YEAR), value = as.numeric(value)) |> 
    mutate(year_month = as.Date(paste(YEAR, month, "1", sep = "-"), format = "%Y-%b-%d")) |> 
    subset(value < 50)
  return(x)
})

salinity_readings_inactive<-bind_rows(salinity_readings_inactive, .id = "lighthouse")







lightstations <- lightstations |> 
  rename(lighthouse = LIGHSTATIO)


merged_light<- salinity_readings |> 
  left_join(lightstations, by = "lighthouse")

merged_light_inactive<- salinity_readings_inactive |> 
  left_join((lightstations), by = "lighthouse")

merged_light_all<- rbind(merged_light, merged_light_inactive)

library(leaflet)
library(leafpop)
library(viridisLite)



summary_stats <- merged_light_all %>%
  group_by(lighthouse) %>%
  summarise(
    mean_value = mean(value, na.rm = TRUE),
    min_value = min(value, na.rm = TRUE),
    max_value = max(value, na.rm = TRUE),
    n_readings = n(), 
    year_range = paste(min(YEAR, na.rm = TRUE), max(YEAR, na.rm = TRUE), sep = " - "),
    geometry = geometry[1],
    .groups = "drop"
  )
summary_stats <- st_as_sf(summary_stats, sf_column_name = "geometry")

n_lighthouses <- n_distinct(summary_stats$lighthouse) 
lighthouse_colors <- viridisLite::viridis(n = n_lighthouses, option = "turbo")

bc = bcmaps::bc_bound() |> sf::st_transform(4326)


summary_stats <- summary_stats %>%
  mutate(color = lighthouse_colors[match(lighthouse, unique(lighthouse))])


leaflet() |> 
  addTiles() |> 

  addPolygons(
    data = bc,
    color = 'black',
    weight = 2,
    fillColor = 'transparent'
  ) |> 
 
  addCircleMarkers(
    data = summary_stats, 
    radius = 6, 
    color = ~color, 
    fillColor = ~color, 
    fillOpacity = 1, 
    stroke = TRUE,
    weight = 1, 
    popup = ~paste0(
      "<strong>Lighthouse:</strong> ", lighthouse, "<br>",
      "<strong>Mean Value:</strong> ", round(mean_value, 2), "<br>",
      "<strong>Min Value:</strong> ", round(min_value, 2), "<br>",
      "<strong>Max Value:</strong> ", round(max_value, 2), "<br>",
      "<strong>Year Range:</strong> ", year_range, "<br>",
      
      "<strong>Number of Readings:</strong> ", n_readings
    )
  ) 
  

