library(openxlsx)
library(tidyverse)
library(data.table)
library(sf)
library(terra)
library(RColorBrewer)
library(ggspatial)
library(tidyterra)

sal_data<- list.files(path="./data/salinity/dataverse_files/", pattern ="\\.csv", full.name = T) 

sal_data <-read.csv("./data/salinity/dataverse_files/salinity_data.csv")



