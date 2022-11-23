#' Returns the UTM EPSG code for a given input
#'
#' Input should be longitude
#'
#' @param input_sf Input polygons as sf
#' @return The EPSG code of the local UTM zone.
#' @export
#'
util_utm_zone <- function(input_sf){

  if(sf::st_geometry_type(input_sf)[1] != "POINT"){
    input_sf <- suppressWarnings({sf::st_centroid(input_sf, silent=TRUE)})
  }

  longitude <- sf::st_coordinates(input_sf)[1]

  utm_z <- floor((longitude + 180) / 6) + 1
  epsg <- NA
  utm_z <- stringr::str_pad(utm_z, 2)
  epsg <- paste0("326", utm_z)
  epsg <- as.numeric(as.character(epsg))


  return(epsg)


}
