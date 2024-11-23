asian_occs = gm_sf |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% asian_countries,]))

# Simplify table to x/y
asian_occs = asian_occs |> 
  dplyr::mutate(x = sf::st_coordinates(geometry)[,1],
                y = sf::st_coordinates(geometry)[,2]) |> 
  dplyr::select(x, y) |> 
  sf::st_drop_geometry()

south_american_occs = gm_sf |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% south_american_countries,]))

# Simplify table to x/y
south_american_occs = south_american_occs |> 
  dplyr::mutate(x = sf::st_coordinates(geometry)[,1],
                y = sf::st_coordinates(geometry)[,2]) |> 
  dplyr::select(x, y) |> 
  sf::st_drop_geometry()

north_american_occs = gm_sf |> 
  sf::st_transform(terra::crs(inf_countries)) |> 
  sf::st_filter(sf::st_as_sf(inf_countries[inf_countries$NAME_0 %in% north_america,]))

# Simplify table to x/y
north_american_occs = north_american_occs |> 
  dplyr::mutate(x = sf::st_coordinates(geometry)[,1],
                y = sf::st_coordinates(geometry)[,2]) |> 
  dplyr::select(x, y) |> 
  sf::st_drop_geometry()
