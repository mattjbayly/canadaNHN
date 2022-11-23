#' Generates RCA Polygons
#'
#' Generates RCA polygons for an NHN region
#'
#' @param basin Class sf (multipolygon). Basin boundary for working unit. Ideally the NHN_WORKUNIT_LIMIT_2
#' @param strm Class sf (multilinestring). Stream lines from NHN working unit (NHN_HN_NLFLOW_1)
#' @param pt_density_m Numeric. RCA point resolution (in meters). Defaults to 50m. Decrease or improve resolution at the cost of processing speed.
#'
#' @details This function should be run after the streamlines are cleaned and topology is corrected. This can be achieved by running `get_upstream_lines` with the junction id from the outlet of the target region. See example.
#'
#' @return None
#'
#' @examples
#' \dontrun{
#'
#' filename_strm <- system.file("extdata", "NHN_HN_NLFLOW_1.gpkg", package = "canadaNHN")
#' filename_basin <- system.file("extdata", "NHN_WORKUNIT_LIMIT_2.gpkg", package = "canadaNHN")
#'
#' # Load example data
#' # NHN Streamlines
#' strm <- sf::st_read(paste0(filename_strm), layer="NHN_HN_NLFLOW_1")
#' # Drop Z geometry
#' strm <- sf::st_zm(strm)
#'
#' # Convert to local UTM zone
#' strm <- sf::st_transform(strm, util_utm_zone(strm))
#' sf::st_crs(strm)$epsg
#' # Basin boundary
#' basin <- sf::st_read(paste0(filename_basin), layer="NHN_WORKUNIT_LIMIT_2")
#'
#' # Recommended: Run get_upstream_lines() first with the basin outlet
#' # this prevents network topology issues with isolated segments
#' outlet_junction <- '310665e2e3dd4738b26b031a85d2bb19'
#' strm_fix <- get_upstream_lines(strm = strm, jnid = outlet_junction)
#'
#'
#' # RCA Polygons from NHN network
#' rca <- generate_rca_polygons(basin = basin, strm = strm_fix, pt_density_m = 50)
#'
#' plot(sf::st_geometry(rca), col = "#e0d7ab", border = "#f7f5e9")
#' plot(sf::st_geometry(strm), col = "#395387", add = TRUE)
#'
#'
#'}
#'
#' @export
generate_rca_polygons <-
  function(basin = NA,
           strm = NA,
           pt_density_m = 50) {

    # Sample points by nid line
    # Interval m - exclude start and end points
    mepsg <- util_utm_zone(basin)
    strm <- sf::st_transform(strm, mepsg)
    basin <- sf::st_transform(basin, mepsg)


    s2 <- strm[, "nid"]

    # Sample points along line at pt_density_m
    lineSamp <-
      function(a, pt_density_m) {
        sf::st_line_sample(
          sf::st_cast(a, "LINESTRING"),
          density = 1 / pt_density_m,
          type = "regular"
        )
      }

    # Line to list
    s2_list <- split(s2, seq(nrow(s2)))
    # Apply point sample function to each element of list
    print("Sampling points along lines...")
    out <-
      suppressWarnings({
        lapply(s2_list, lineSamp, pt_density_m = pt_density_m)
      })

    # Convert to dataframe sf class
    print("Converting to class sf")
    outr <-
      suppressWarnings({
        lapply(
          out,
          FUN = function(x)
            sf::st_as_sf(x)
        )
      })

    # Add nid to list
    for (i in seq_along(outr)) {
      outr[[i]]$nid <- as.character(s2$nid[[i]])
    }

    # Merge data together
    temp_dt <- outr
    outr2 <- data.table::rbindlist(temp_dt)
    coords <- sf::st_coordinates(outr2$x)
    coords <- as.data.frame(coords)
    coords$nid <- s2$nid[coords$L1]

    # Conversions
    samppts <-
      sf::st_as_sf(coords,
                   coords = c("X", "Y"),
                   crs = mepsg,
                   agr = "constant")
    # check it out plot(sf::st_geometry(samppts))

    # Generate polys via terra
    samppts_sv <- terra::vect(samppts)
    basin_sv <- terra::vect(basin)
    vpoly <- terra::voronoi(samppts_sv, bnd = basin_sv)
    vdiss <- terra::aggregate(vpoly, by = "nid", dissolve = TRUE)

    rca <- sf::st_as_sf(vdiss)

    # Clip by basin extent
    clip <- sf::st_geometry(basin)
    output <- suppressWarnings({
      sf::st_intersection(rca, clip)
    })
    output$mean_L1 <- NULL
    output$agg_n <- NULL

    # Check it out plot(sf::st_geometry(output))

    return(output)



  }
