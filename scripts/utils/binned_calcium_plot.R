  library(terra)
  library(ggplot2)
  library(bcmaps)
  library(stringr)
  library(bcdata)
  library(dplyr)
  
  lan_root = "//SFP.IDIR.BCGOV/S140/S40203/RSD_ FISH & AQUATIC HABITAT BRANCH/General/"
  proj_wd = getwd()
  onedrive_wd = paste0(str_extract(getwd(),"C:/Users/[A-Z]+/"),"OneDrive - Government of BC/data/")
  
  
  bc<-bc_bound() |> st_transform(4326)
  
  calc_na<-terra::rast(paste0(onedrive_wd, "CNF/calcium-KR-97648-median_10km_ZN_masked.tif"))
  calc_na<-terra::project(calc_na, "EPSG:4326")
  names(calc_na)<-"value"
  
  bc_calc<-terra::mask(terra::crop(calc_na, bc), bc)
  
  plot(bc_calc)
  
  bc_watersheds <- st_read(paste0(onedrive_wd,"CNF/watershed_groups.gpkg"))
  plot(st_geometry(bc_watersheds))
  
  average_calcium <- extract(bc_calc, bc_watersheds, fun = mean, na.rm = TRUE)
  
  bc_watersheds$ca_avg<-average_calcium[,2]
  
  ggplot(data = bc_watersheds) +
    geom_sf(aes(fill = ca_avg), color = "black", size = 0.1) +  # Fill with calcium values
    scale_fill_viridis_c(option = "YlOrRd", na.value = "gray", name = "Calcium Avg") +  # Gradient scale
    ggtitle("Watersheds with Average Calcium Levels") +
    theme_minimal() +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 14, face = "bold")
    )

  low_risk<-1
  medium_risk<-3
  #high_risk<-5
  
  
  bc_watersheds <- bc_watersheds |> 
    mutate(
      calcium_bin = case_when(
        ca_avg <= low_risk ~ "Low",
        ca_avg > low_risk & ca_avg <= medium_risk ~ "Medium",
        ca_avg > medium_risk ~ "High",
        is.na(ca_avg) ~ "No Data"  # Handle missing values if needed
      )
    )
  
  bc_watersheds$calcium_bin <- factor(
    bc_watersheds$calcium_bin,
    levels = c("Low", "Medium", "High", "No Data")  # Include "No Data" if applicable
  )
  
  binned_map<-ggplot(data = bc_watersheds) +
    geom_sf(aes(fill = calcium_bin), color = "black", size = 0.1) +
    scale_fill_manual(
      values = c(
        "Low" = "yellow",
        "Medium" = "orange",
        "High" = "red",
        "No Data" = "gray"
      ),
      name = "Calcium Levels"
    ) +
    ggtitle("Watersheds with Ca Levels for Golden Mussel Survival") +
    theme_minimal() +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 14, face = "bold")
    )
  
  ggsave(
    filename = "watersheds_calcium_levels_golden_mussel.png", 
    plot = last_plot(),                   
    width = 10,                                  
    height = 8,                                  
    dpi = 300                               
  )
  