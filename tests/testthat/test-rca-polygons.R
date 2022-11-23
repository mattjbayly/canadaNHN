test_that("Test RCA Polygons", {

  # ---------------------------------------------------
  expect_true(1 == 1)

  filename_junc <- system.file("extdata", "NHN_HN_HYDROJUNCT_0.gpkg", package = "canadaNHN")
  filename_strm <- system.file("extdata", "NHN_HN_NLFLOW_1.gpkg", package = "canadaNHN")
  filename_basin <- system.file("extdata", "NHN_WORKUNIT_LIMIT_2.gpkg", package = "canadaNHN")

  # Load example data
  # NHN Junctions
  junc <- sf::st_read(paste0(filename_junc), layer="NHN_HN_HYDROJUNCT_0")
  # NHN Streamlines
  strm <- sf::st_read(paste0(filename_strm), layer="NHN_HN_NLFLOW_1")
  # Drop Z geometry
  strm <- sf::st_zm(strm)
  sf::st_crs(strm)
  # Basin boundary
  basin <- sf::st_read(paste0(filename_basin), layer="NHN_WORKUNIT_LIMIT_2")

  # RCA Polygons from NHN network
  rca <- generate_rca_polygons(basin = basin, strm = strm, pt_density_m = 200)

  # RCA to stream should have a 1:1 ratio
  c1 <- length(unique(rca$nid))
  c2 <- length(unique(strm$nid))
  expect_true(c1 <= c2)

  # No duplicates
  expect_false(any(duplicated(rca$nid)))

  # No duplicates
  expect_false(any(duplicated(strm$nid)))






})
