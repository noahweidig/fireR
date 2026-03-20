#' Download MTBS perimeter data
#'
#' Downloads the MTBS composite burned-area extent ZIP archive to a directory.
#' If the ZIP already exists and \code{overwrite = FALSE}, no network call is
#' made.
#'
#' @param url \code{character(1)} URL of the MTBS perimeter ZIP archive.
#' @param directory \code{character(1)} directory where
#'   \code{mtbs_perimeter_data.zip} is stored.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param retries \code{integer(1)} number of download retry attempts.
#' @param timeout \code{integer(1)} timeout in seconds for each download
#'   attempt.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the downloaded ZIP file (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' mtbs_dir <- download_mtbs()
#' }

get_mtbs <- function(
    directory = getwd(),
    overwrite = FALSE,
    verbose   = TRUE
) {
  url <- "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip"
  zip_file <- fs::path(directory, "mtbs_perimeter_data.zip")
  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading MTBS perimeter data …")
    utils::download.file(url, zip_file, mode = "wb", quiet = !verbose)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("MTBS ZIP already exists: {.path {zip_file}}")
  }

  invisible(zip_file)
}

#' Read MTBS fire perimeter data
#'
#' Reads MTBS fire perimeters from an existing local MTBS ZIP downloaded with
#' [get_mtbs()] and returns either a spatial object or a plain attribute table.
#'
#' `read_mtbs()` does not download data.
#'
#' @param url \code{character(1)} retained for backward compatibility; not used
#'   by \code{read_mtbs()}.
#' @param years \code{integer} vector of length 1 or 2 specifying the year
#'   range to keep. If a single year is supplied, only fires from that year
#'   are returned. If two years are supplied they are treated as
#'   \code{c(start_year, end_year)} (inclusive). \code{NULL} (the default)
#'   returns all years without filtering.
#' @param type \code{character} vector of incident types to keep, matched
#'   against the \code{Incid_Type} column. Valid values are
#'   \code{"Wildfire"}, \code{"Prescribed Fire"}, \code{"Unknown"}, and
#'   \code{"Wildland Fire Use"}. \code{NULL} (the
#'   default) returns all incident types.
#' @param geometry \code{logical(1)} When \code{TRUE} (the default) the
#'   result is a spatial object (\code{sf} or \code{terra::SpatVector}
#'   depending on \code{output}). When \code{FALSE} the shapefile attributes
#'   are returned as a plain \code{data.frame} with the geometry column
#'   dropped.
#' @param output \code{character(1)} The class of the returned spatial
#'   object. Either \code{"vect"} / \code{"terra"} (default) for a
#'   \code{terra::SpatVector}, or \code{"sf"} for an \code{sf} object.
#'   Ignored when \code{geometry = FALSE}.
#' @param cache \code{logical(1)} or \code{character(1)}. When \code{FALSE}
#'   (the default) data are read from the current working directory. When
#'   \code{TRUE} data are read from
#'   \code{tools::R_user_dir("fireR", "cache")}. Alternatively, supply a
#'   directory path as a string to control the location.
#' @param overwrite \code{logical(1)} retained for backward compatibility; not
#'   used by \code{read_mtbs()}.
#' @param retries \code{integer(1)} retained for backward compatibility; not
#'   used by \code{read_mtbs()}.
#' @param timeout \code{integer(1)} retained for backward compatibility; not
#'   used by \code{read_mtbs()}.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return
#' \itemize{
#'   \item A \code{terra::SpatVector} when \code{output = "vect"} /
#'     \code{"terra"} and \code{geometry = TRUE}.
#'   \item An \code{sf} object when \code{output = "sf"} and
#'     \code{geometry = TRUE}.
#'   \item A \code{data.frame} when \code{geometry = FALSE}.
#' }
#'
#' @details
#' `read_mtbs()` does not download data. Download the ZIP first with [get_mtbs()].
#'
#' @examples
#' \dontrun{
#' fires <- read_mtbs()
#' fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")
#' tbl <- read_mtbs(geometry = FALSE)
#' }
#' @export
read_mtbs <- function(
    zip_file,
    years    = NULL,
    type     = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    verbose  = TRUE
) {
  output <- rlang::arg_match(output)
  if (!fs::file_exists(zip_file)) stop("ZIP file not found: ", zip_file)

  # Validate years
  if (!is.null(years)) {
    years <- as.integer(years)
    if (length(years) == 1L) years <- c(years, years)
    if (length(years) > 2L) stop("`years` must be length 1 or 2")
    years <- sort(years)
  }

  # Validate types
  valid_types <- c("Wildfire", "Prescribed Fire", "Unknown",
                   "Wildland Fire Use", "Complex")
  if (!is.null(type)) {
    bad <- setdiff(type, valid_types)
    if (length(bad) > 0L) stop("Unknown type: ", paste(bad, collapse=", "))
  }

  # Find shapefile inside ZIP
  zip_contents <- utils::unzip(zip_file, list = TRUE)
  shp_idx <- grep("\\.shp$", zip_contents$Name, ignore.case = TRUE)
  if (length(shp_idx) == 0L) stop("No .shp found in ZIP")
  shp_in_zip <- zip_contents$Name[[shp_idx[[1L]]]]
  shp_path <- sprintf("/vsizip/%s/%s", normalizePath(zip_file, winslash="/"), shp_in_zip)

  # Build SQL query
  layer <- tools::file_path_sans_ext(basename(shp_in_zip))
  where_clauses <- character(0)

  if (!is.null(years)) {
    where_clauses <- c(
      where_clauses,
      sprintf("CAST(Ig_Date AS character(10)) >= '%04d-01-01' AND CAST(Ig_Date AS character(10)) <= '%04d-12-31'",
              years[1], years[2])
    )
  }
  if (!is.null(type)) {
    type_eq <- paste(sprintf("Incid_Type = '%s'", type), collapse=" OR ")
    where_clauses <- c(where_clauses, sprintf("(%s)", type_eq))
  }
  sql_query <- if (length(where_clauses) > 0L) {
    sprintf('SELECT * FROM "%s" WHERE %s', layer, paste(where_clauses, collapse = " AND "))
  } else NULL

  # Read data
  if (verbose) cli::cli_inform("Reading {.path {basename(shp_in_zip)}} …")
  data_sv <- if (!is.null(sql_query)) {
    terra::vect(shp_path, query = sql_query)
  } else {
    terra::vect(shp_path)
  }

  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}
