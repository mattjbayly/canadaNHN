#' Get Upstream Basin Poylgons
#'
#' Collect all NHN RCA lines upstream from a junction point.
#'
#' @param jnid Watershed outlet NHN junction nid. Junction ID from NHN_HN_HYDROJUNCT_0 e.g., "92607204bc7e4dcb939fbc57b709be0b"
#' @param strm Class sf (multilinestring). Stream lines from NHN working unit (NHN_HN_NLFLOW_1)
#' @param rca Class sf (polygon). RCA polygon object returned from `generate_rca_polygons`
#' @param dissolve should final basin be returned as a dissolved watershed polygon or broken up into RCA polygons? Default is TRUE
#'
#' @details Function takes in a target watershed outlet nid `jnid`, RCA polygons and a streamline layer. Function calculates a pseudo upstream drainage basin boundary from a point.
#'
#' @return Watershed basin upstream from a point.
#'
#' @examples
#'
#' \dontrun{
#'
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
#'
#' # Convert to local UTM zone
#' strm <- sf::st_transform(strm, util_utm_zone(strm))
#' sf::st_crs(strm)$epsg
#' # Basin boundary
#' basin <- sf::st_read(paste0(filename_basin), layer="NHN_WORKUNIT_LIMIT_2")
#'
#'
#' # Recommended: Run get_upstream_lines() first with the basin outlet
#' # this prevents network topology issues with isolated segments
#'
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
#' # Identify target junction ID for upstream delineation
#' target_junction <- "c2ad6151e60a49dbabcb59d85eda4cba"
#'
#' watershed <- get_upstream_polygons(
#'      jnid = target_junction,
#'      strm = strm,
#'      rca = rca,
#'      dissolve = TRUE)
#'
#' # View result
#' plot(sf::st_geometry(watershed), col = "pink", add = TRUE)
#' out_sl <- strm[strm$fromJunction == target_junction, ]
#' plot(sf::st_geometry(strm), col = "#395387", add = TRUE)
#' plot(sf::st_geometry(out_sl), add = TRUE, col = "yellow", lwd = 3)
#'
#'}
#'
#' @export
#'
get_upstream_polygons <- function(jnid = NA,
                                  strm = NA,
                                  rca = NA,
                                  dissolve = TRUE) {
  jnid_step <- jnid
  counter <- 1
  all_seg <- list()
  strm$toJunction <- as.character(strm$toJunction)


  strm_sub <- get_upstream_lines(strm = strm,
                     jnid = jnid,
                     us_limit = 100000)


  # Get all streamline IDs
  all_seg <- unique(strm_sub$nid)


  # Get RCA polygons from line IDs
  polysub <- rca[which(rca$nid %in% all_seg),]

  polyret <- polysub
  # plot(sf::st_geometry(polysub), col="pink")

  # Dissolve watershed
  if (dissolve) {

    polysub$group <- 1
    polydiss <- polysub %>% dplyr::group_by(group) %>% dplyr::summarise()
    #plot(st_geometry(polyret), col="pink")

    diss <- nngeo::st_remove_holes(polydiss)
    #plot(sf::st_geometry(diss))

    polyret <- diss

  }

  return(polyret)

}
