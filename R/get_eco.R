# Internal helper: download a ZIP and read the shapefile inside it.
.read_eco_zip <- function(url, zip_name, output, cache, verbose) {
  cache_dir <- if (isTRUE(cache)) {
    tools::R_user_dir("fireR", "cache")
  } else if (isFALSE(cache)) {
    tempdir()
  } else {
    as.character(cache)
  }

  zip_file <- fs::path(cache_dir, zip_name)
  fs::dir_create(cache_dir, recurse = TRUE)

  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading {zip_name} \u2026")
    old_timeout <- options(timeout = 3600)
    on.exit(options(old_timeout), add = TRUE)
    utils::download.file(url, zip_file, mode = "wb", quiet = !verbose)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("Using cached file: {.path {zip_file}}")
  }

  zip_contents <- utils::unzip(zip_file, list = TRUE)
  shp_idx <- grep("\\.shp$", zip_contents$Name, ignore.case = TRUE)
  if (length(shp_idx) == 0L) stop("No .shp found in ZIP: ", zip_name)
  shp_in_zip <- zip_contents$Name[[shp_idx[[1L]]]]
  shp_path <- sprintf(
    "/vsizip/%s/%s",
    normalizePath(zip_file, winslash = "/"),
    shp_in_zip
  )

  if (verbose) cli::cli_inform("Reading {.path {basename(shp_in_zip)}} \u2026")
  data_sv <- terra::vect(shp_path)

  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}

#' Download and load North America Level 1 Ecoregions
#'
#' Downloads and loads the Commission for Environmental Cooperation (CEC)
#' North America Level 1 Ecoregion boundaries as a spatial object.
#'
#' @section About CEC Ecoregions:
#' The Commission for Environmental Cooperation (CEC) North American ecoregion
#' framework divides the continent into hierarchical levels based on similarity
#' of ecosystems and the type, quality, and quantity of environmental
#' resources.  Level 1 represents the broadest ecological divisions of the
#' continent.  Data are sourced from the US EPA / CEC ecoregion mapping
#' programme.
#'
#' @param output \code{character(1)} class of the returned spatial object.
#'   Either \code{"sf"} (default) or \code{"vect"} / \code{"terra"} for a
#'   \code{terra::SpatVector}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where the
#'   ZIP is cached.  \code{FALSE} (the default) uses a temporary directory that
#'   is cleaned up when the R session ends.  \code{TRUE} uses the platform user
#'   cache directory (\code{tools::R_user_dir("fireR", "cache")}).  Supply a
#'   directory path as a string to specify a custom location.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return An \code{sf} object or \code{terra::SpatVector} of North America
#'   Level 1 Ecoregion polygons.
#' @export
#'
#' @examples
#' \dontrun{
#' eco <- get_nal1eco()
#' eco_terra <- get_nal1eco(output = "vect")
#' }
get_nal1eco <- function(
    output  = c("sf", "vect", "terra"),
    cache   = FALSE,
    verbose = TRUE
) {
  output <- rlang::arg_match(output)
  .read_eco_zip(
    url      = "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/cec_na/na_cec_eco_l1.zip",
    zip_name = "na_cec_eco_l1.zip",
    output   = output,
    cache    = cache,
    verbose  = verbose
  )
}

#' Download and load North America Level 2 Ecoregions
#'
#' Downloads and loads the Commission for Environmental Cooperation (CEC)
#' North America Level 2 Ecoregion boundaries as a spatial object.
#'
#' @section About CEC Ecoregions:
#' The Commission for Environmental Cooperation (CEC) North American ecoregion
#' framework divides the continent into hierarchical levels based on similarity
#' of ecosystems and the type, quality, and quantity of environmental
#' resources.  Level 2 subdivides the Level 1 regions into finer ecological
#' units.  Data are sourced from the US EPA / CEC ecoregion mapping programme.
#'
#' @param output \code{character(1)} class of the returned spatial object.
#'   Either \code{"sf"} (default) or \code{"vect"} / \code{"terra"} for a
#'   \code{terra::SpatVector}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where the
#'   ZIP is cached.  \code{FALSE} (the default) uses a temporary directory that
#'   is cleaned up when the R session ends.  \code{TRUE} uses the platform user
#'   cache directory (\code{tools::R_user_dir("fireR", "cache")}).  Supply a
#'   directory path as a string to specify a custom location.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return An \code{sf} object or \code{terra::SpatVector} of North America
#'   Level 2 Ecoregion polygons.
#' @export
#'
#' @examples
#' \dontrun{
#' eco <- get_nal2eco()
#' eco_terra <- get_nal2eco(output = "vect")
#' }
get_nal2eco <- function(
    output  = c("sf", "vect", "terra"),
    cache   = FALSE,
    verbose = TRUE
) {
  output <- rlang::arg_match(output)
  .read_eco_zip(
    url      = "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/cec_na/na_cec_eco_l2.zip",
    zip_name = "na_cec_eco_l2.zip",
    output   = output,
    cache    = cache,
    verbose  = verbose
  )
}

#' Download and load North America Level 3 Ecoregions
#'
#' Downloads and loads the Commission for Environmental Cooperation (CEC)
#' North America Level 3 Ecoregion boundaries as a spatial object.
#'
#' @section About CEC Ecoregions:
#' The Commission for Environmental Cooperation (CEC) North American ecoregion
#' framework divides the continent into hierarchical levels based on similarity
#' of ecosystems and the type, quality, and quantity of environmental
#' resources.  Level 3 provides the finest continental-scale subdivisions,
#' corresponding to the US EPA Level III ecoregions.  Data are sourced from
#' the US EPA / CEC ecoregion mapping programme.
#'
#' @param output \code{character(1)} class of the returned spatial object.
#'   Either \code{"sf"} (default) or \code{"vect"} / \code{"terra"} for a
#'   \code{terra::SpatVector}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where the
#'   ZIP is cached.  \code{FALSE} (the default) uses a temporary directory that
#'   is cleaned up when the R session ends.  \code{TRUE} uses the platform user
#'   cache directory (\code{tools::R_user_dir("fireR", "cache")}).  Supply a
#'   directory path as a string to specify a custom location.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return An \code{sf} object or \code{terra::SpatVector} of North America
#'   Level 3 Ecoregion polygons.
#' @export
#'
#' @examples
#' \dontrun{
#' eco <- get_nal3eco()
#' eco_terra <- get_nal3eco(output = "vect")
#' }
get_nal3eco <- function(
    output  = c("sf", "vect", "terra"),
    cache   = FALSE,
    verbose = TRUE
) {
  output <- rlang::arg_match(output)
  .read_eco_zip(
    url      = "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/cec_na/NA_CEC_Eco_Level3.zip",
    zip_name = "NA_CEC_Eco_Level3.zip",
    output   = output,
    cache    = cache,
    verbose  = verbose
  )
}

#' Download and load US Level 3 Ecoregions
#'
#' Downloads and loads US EPA Level 3 Ecoregion boundaries as a spatial
#' object, optionally including state boundaries.
#'
#' @section About US EPA Ecoregions:
#' The US EPA ecoregion framework classifies areas of the United States by
#' similarity of ecosystems and environmental resources.  Level 3 provides
#' finer subdivisions of the Level 2 regions and is widely used for
#' environmental assessment, monitoring, and reporting at regional scales.
#' Data are sourced from the US EPA Office of Research and Development.
#'
#' @param state \code{logical(1)} when \code{TRUE}, the dataset with state
#'   boundaries dissolved into the ecoregion polygons is returned.  Defaults
#'   to \code{FALSE}.
#' @param output \code{character(1)} class of the returned spatial object.
#'   Either \code{"sf"} (default) or \code{"vect"} / \code{"terra"} for a
#'   \code{terra::SpatVector}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where the
#'   ZIP is cached.  \code{FALSE} (the default) uses a temporary directory that
#'   is cleaned up when the R session ends.  \code{TRUE} uses the platform user
#'   cache directory (\code{tools::R_user_dir("fireR", "cache")}).  Supply a
#'   directory path as a string to specify a custom location.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return An \code{sf} object or \code{terra::SpatVector} of US Level 3
#'   Ecoregion polygons.
#' @export
#'
#' @examples
#' \dontrun{
#' eco <- get_usl3eco()
#' eco_state <- get_usl3eco(state = TRUE)
#' eco_terra <- get_usl3eco(output = "vect")
#' }
get_usl3eco <- function(
    state   = FALSE,
    output  = c("sf", "vect", "terra"),
    cache   = FALSE,
    verbose = TRUE
) {
  output <- rlang::arg_match(output)
  if (state) {
    url      <- "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/us/us_eco_l3_state_boundaries.zip"
    zip_name <- "us_eco_l3_state_boundaries.zip"
  } else {
    url      <- "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/us/us_eco_l3.zip"
    zip_name <- "us_eco_l3.zip"
  }
  .read_eco_zip(
    url      = url,
    zip_name = zip_name,
    output   = output,
    cache    = cache,
    verbose  = verbose
  )
}

#' Download and load US Level 4 Ecoregions
#'
#' Downloads and loads US EPA Level 4 Ecoregion boundaries as a spatial
#' object, optionally including state boundaries.
#'
#' @section About US EPA Ecoregions:
#' The US EPA ecoregion framework classifies areas of the United States by
#' similarity of ecosystems and environmental resources.  Level 4 provides
#' the finest sub-divisions in the US ecoregion hierarchy, capturing local
#' ecological patterns within Level 3 regions.  These are commonly used for
#' site-level assessments and detailed environmental monitoring.
#' Data are sourced from the US EPA Office of Research and Development.
#'
#' @param state \code{logical(1)} when \code{TRUE}, the dataset with state
#'   boundaries dissolved into the ecoregion polygons is returned.  Defaults
#'   to \code{FALSE}.
#' @param output \code{character(1)} class of the returned spatial object.
#'   Either \code{"sf"} (default) or \code{"vect"} / \code{"terra"} for a
#'   \code{terra::SpatVector}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where the
#'   ZIP is cached.  \code{FALSE} (the default) uses a temporary directory that
#'   is cleaned up when the R session ends.  \code{TRUE} uses the platform user
#'   cache directory (\code{tools::R_user_dir("fireR", "cache")}).  Supply a
#'   directory path as a string to specify a custom location.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return An \code{sf} object or \code{terra::SpatVector} of US Level 4
#'   Ecoregion polygons.
#' @export
#'
#' @examples
#' \dontrun{
#' eco <- get_usl4eco()
#' eco_state <- get_usl4eco(state = TRUE)
#' eco_terra <- get_usl4eco(output = "vect")
#' }
get_usl4eco <- function(
    state   = FALSE,
    output  = c("sf", "vect", "terra"),
    cache   = FALSE,
    verbose = TRUE
) {
  output <- rlang::arg_match(output)
  if (state) {
    url      <- "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/us/us_eco_l4_state_boundaries.zip"
    zip_name <- "us_eco_l4_state_boundaries.zip"
  } else {
    url      <- "https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/us/us_eco_l4.zip"
    zip_name <- "us_eco_l4.zip"
  }
  .read_eco_zip(
    url      = url,
    zip_name = zip_name,
    output   = output,
    cache    = cache,
    verbose  = verbose
  )
}
