
# Grab occurrence records for Golden Mussel across the globe from iNaturalist.
gm_oc = rinat::get_inat_obs(taxon_name = "Limnoperna fortunei",maxresults = 10000)

# Convert table from iNaturalist query to a spatial table (sf object)
gm_sf = gm_oc |> 
  dplyr::rename(Species = common_name) |> 
  tidyr::as_tibble() |> 
  sf::st_as_sf(coords = c("longitude","latitude"), crs = 4326)

