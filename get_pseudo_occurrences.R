
invisible(gc())

asian_pseudos = predicts::backgroundSample(asian_country_r,
                                     p = terra::vect(gm_sf),
                                     n = 10000,
                                     extf = 0.9,
                                     tryf = 500) |>
  tidyr::as_tibble()

# print("Grabbed asian pseudoabsences")

south_american_pseudos = predicts::backgroundSample(south_american_country_r,
                                           p = terra::vect(gm_sf),
                                           n = 10000,
                                           extf = 0.9,
                                           tryf = 500) |>
  tidyr::as_tibble()

# print("Grabbed south american pseudoabsences")

north_american_pseudos = predicts::backgroundSample(north_american_country_r,
                                                    p = terra::vect(gm_sf),
                                                    n = 10000,
                                                    extf = 0.9,
                                                    tryf = 500) |>
  tidyr::as_tibble()

# print("Grabbed north american pseudoabsences")