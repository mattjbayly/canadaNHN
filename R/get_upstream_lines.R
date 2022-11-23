#' Get upstream lines
#'
#' Trace upstream flow lines from a point
#'
#' @param strm Class sf (multilinestring). Stream lines from NHN working unit (NHN_HN_NLFLOW_1)
#' @param jnid Character. Junction ID from NHN_HN_HYDROJUNCT_0 e.g., "92607204bc7e4dcb939fbc57b709be0b"
#' @param us_limit Numeric. Number of iterations upstream steps
#'
#' @details Get upstream lines following all upstream flow paths from a junction ID. Inputs include the streamline layer, jnid junction ID and us_limit (a special parameter specifying how many steps to take).
#'
#' @return Upstream lines
#'
#' @examples
#' \dontrun{
#'
#' # Get upstream lines from the following target junction:
#' target_junction <- "c2ad6151e60a49dbabcb59d85eda4cba"
#'
#' # Load example data
#' filename_strm <- system.file("extdata", "NHN_HN_NLFLOW_1.gpkg", package = "canadaNHN")
#' strm <- sf::st_read(paste0(filename_strm), layer="NHN_HN_NLFLOW_1")
#' strm <- sf::st_zm(strm)
#' us_lines <- get_upstream_lines(strm = strm,
#' jnid = target_junction,
#' us_limit = 1000)
#' plot(sf::st_geometry(strm))
#' plot(sf::st_geometry(us_lines), add = TRUE, col = "red")
#' out_sl <- strm[strm$fromJunction == target_junction, ]
#' plot(sf::st_geometry(out_sl), add = TRUE, col = "yellow", lwd = 3)
#' # mapview(ds_lines)
#'
#' }
#'
get_upstream_lines <-
  function(strm = NA,
           jnid = "c2ad6151e60a49dbabcb59d85eda4cba",
           us_limit = 1000) {

    #jnid <- "4935e1b98e2b486d8540aeb639f33f9e"
    #jnid <- "bb241d75f0b5448eb928f645526b7ba8"
    #jnid <- "ff9c68ee6f904af79416e69efe8a737b"


    # Filter on flow direction
    strm <- strm[which(strm$flowDirection == 1),]

    jnid_step <- jnid
    counter <- 1
    all_seg <- list()
    strm$toJunction <- as.character(strm$toJunction)

    while (counter < us_limit) {
      to_junc <-
        strm$fromJunction[which(strm$toJunction %in% as.character(jnid_step))]

      tnid <- strm$nid[which(strm$toJunction %in% jnid_step)]
      all_seg[[counter]] <- as.character(tnid)

      jnid_step <- as.character(to_junc)
      if (length(jnid_step) == 0) {
        break
      }

      counter <- counter + 1
      #print(counter)
    }

    all_seg <- unlist(all_seg)
    all_seg <- unique(all_seg)

    # QA - REVIEW
    if(FALSE) {
      strm_sub <- strm[which(strm$nid %in% all_seg), ]
      #print(nrow(strm_sub))
      strm_sub <- sf::st_zm(strm_sub)
      plot(sf::st_geometry(strm), col = "black")
      plot(
        sf::st_geometry(strm_sub),
        col = "red",
        lwd = 2,
        add = TRUE
      )
      outlet <- strm[which(strm$fromJunction == jnid), ]
      plot(
        sf::st_geometry(outlet),
        col = "yellow",
        lwd = 3,
        add = TRUE
      )
    }



    # Make sure return list is unique
    all_seg <- unique(all_seg)
    strm_sub <- strm[which(strm$nid %in% all_seg), ]

    return(strm_sub)

  }
