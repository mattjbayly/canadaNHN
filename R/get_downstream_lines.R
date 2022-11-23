#' Get downstream lines
#'
#' Trace downstream flow lines from a point
#'
#' @param strm Class sf (multilinestring). Stream lines from NHN working unit (NHN_HN_NLFLOW_1)
#' @param jnid Character. Junction ID from NHN_HN_HYDROJUNCT_0 e.g., "92607204bc7e4dcb939fbc57b709be0b"
#' @param ds_sreach Numeric. Number of iterations downstream step limit.
#'
#' @details Trace the downstream flow path from an NHN junction nid. Inputs include the streamline vector layer, `jnid` junction nid and ds_reach (a special parameter specifying how many steps to take).
#'
#' @return Downstream streamlines from a junction point
#'
#' @examples
#' \dontrun{
#' filename_strm <- system.file("extdata", "NHN_HN_NLFLOW_1.gpkg", package = "canadaNHN")
#'
#' # Load example data
#' strm <- sf::st_read(paste0(filename_strm), layer="NHN_HN_NLFLOW_1")
#' strm <- sf::st_zm(strm)
#' ds_lines <- get_downstream_lines(strm = strm,
#' jnid = "484667c6025244219cfa5e5ee994715b",
#' ds_sreach = 1000)
#' plot(sf::st_geometry(strm))
#' plot(sf::st_geometry(ds_lines), add = TRUE, col = "red")
#' # mapview(ds_lines)
#' }
#'
get_downstream_lines <-
  function(strm = NA,
           jnid = "92607204bc7e4dcb939fbc57b709be0b",
           ds_sreach = 5000) {

    # jnid = 'a7784e76641748eeabe5c08ed25f2adf'

    jnid_step <- jnid
    counter <- 1
    all_seg <- list()
    strm$toJunction <- as.character(strm$toJunction)

    suppressWarnings({
    while (counter < ds_sreach) {
      to_junc <-
        strm$toJunction[which(strm$fromJunction %in% as.character(jnid_step))]
      tnid <- strm$nid[which(strm$fromJunction %in% jnid_step)]
      all_seg[[counter]] <- as.character(tnid)
      jnid_step <- as.character(to_junc)
      if (length(jnid_step) == 0) {
        break
      }
      counter <- counter + 1
    }
    })
    all_seg <- unlist(all_seg)
    all_seg <- unique(all_seg)

    strm_sub <- strm[which(strm$nid %in% all_seg),]
    #print(nrow(strm_sub))
    #plot(st_geometry(strm_sub), col="pink",lwd=2.5)
    return(strm_sub)

  }
