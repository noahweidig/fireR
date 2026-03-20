#' Download MTBS perimeter or occurrence data
#'
#' Downloads an MTBS composite data ZIP archive to a directory.
#' If the ZIP already exists and \code{overwrite = FALSE}, no network call is
#' made.
#'
#' @param directory \code{character(1)} directory where the ZIP file is stored.
#'   Defaults to the current working directory.
#' @param dataset \code{character(1)} which dataset to download. Use
#'   \code{"perimeters"} (default) to get fire perimeters as polygons, or
#'   \code{"occurrence"} to get fire centroids as points.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param timeout \code{numeric(1)} download timeout in seconds. The MTBS ZIP
#'   is ~360 MB, so the default is \code{3600} (one hour). Set to a lower
#'   value if you want a stricter limit.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the downloaded ZIP file (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' zip_path <- get_mtbs()
#' zip_path_pts <- get_mtbs(dataset = "occurrence")
#' }
get_mtbs <- function(
    directory = getwd(),
    dataset   = c("perimeters", "occurrence"),
    overwrite = FALSE,
    timeout   = 3600,
    verbose   = TRUE
) {
  dataset <- rlang::arg_match(dataset)

  if (dataset == "occurrence") {
    url      <- "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/fod_pt_shapefile/mtbs_fod_pts_data.zip"
    zip_name <- "mtbs_fod_pts_data.zip"
  } else {
    url      <- "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip"
    zip_name <- "mtbs_perimeter_data.zip"
  }

  zip_file <- fs::path(directory, zip_name)
  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading MTBS {dataset} data \u2026")
    old_timeout <- options(timeout = timeout)
    on.exit(options(old_timeout), add = TRUE)
    utils::download.file(url, zip_file, mode = "wb", quiet = !verbose)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("MTBS ZIP already exists: {.path {zip_file}}")
  }

  invisible(zip_file)
}

#' Read MTBS fire perimeter data
#'
#' Reads MTBS fire perimeters from a local MTBS ZIP downloaded with
#' [get_mtbs()] and returns either a spatial object or a plain attribute table.
#'
#' `read_mtbs()` does not download data. Use [get_mtbs()] first to obtain the
#' ZIP archive.
#'
#' @param years \code{integer} vector of length 1 or 2 specifying the year
#'   range to keep. If a single year is supplied, only fires from that year
#'   are returned. If two years are supplied they are treated as
#'   \code{c(start_year, end_year)} (inclusive). \code{NULL} (the default)
#'   returns all years without filtering.
#' @param type \code{character} vector of incident types to keep, matched
#'   against the \code{Incid_Type} column. Valid values are
#'   \code{"Wildfire"}, \code{"Prescribed Fire"}, \code{"Unknown"}, and
#'   \code{"Wildland Fire Use"}. \code{NULL} (the default) returns all
#'   incident types.
#' @param geometry \code{logical(1)} When \code{TRUE} (the default) the
#'   result is a spatial object (\code{sf} or \code{terra::SpatVector}
#'   depending on \code{output}). When \code{FALSE} the shapefile attributes
#'   are returned as a plain \code{data.frame} with the geometry column
#'   dropped.
#' @param output \code{character(1)} The class of the returned spatial
#'   object. Either \code{"vect"} / \code{"terra"} (default) for a
#'   \code{terra::SpatVector}, or \code{"sf"} for an \code{sf} object.
#'   Ignored when \code{geometry = FALSE}.
#' @param cache \code{logical(1)} or \code{character(1)}. Controls where
#'   \code{read_mtbs()} looks for the downloaded ZIP file. When \code{FALSE}
#'   (the default) the current working directory is used. When \code{TRUE}
#'   the platform user cache directory
#'   (\code{tools::R_user_dir("fireR", "cache")}) is used. Supply a
#'   directory path as a string to specify a custom location.
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
#' @examples
#' \dontrun{
#' zip_path <- get_mtbs()
#' fires <- read_mtbs(output = "sf")
#' fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")
#' tbl <- read_mtbs(geometry = FALSE)
#' }
#' @export
read_mtbs <- function(
    years    = NULL,
    type     = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    cache    = FALSE,
    verbose  = TRUE
) {
  output <- rlang::arg_match(output)

  # Validate geometry
  if (!is.logical(geometry) || length(geometry) != 1L || is.na(geometry)) {
    stop("`geometry` must be TRUE or FALSE")
  }

  # Validate years
  if (!is.null(years)) {
    years <- as.integer(years)
    if (length(years) > 2L) stop("`years` must be length 1 or 2")
    if (length(years) == 1L) years <- c(years, years)
    years <- sort(years)
  }

  # Validate types
  valid_types <- c("Wildfire", "Prescribed Fire", "Unknown", "Wildland Fire Use")
  if (!is.null(type)) {
    bad <- setdiff(type, valid_types)
    if (length(bad) > 0L) stop("Unknown type: ", paste(bad, collapse = ", "))
  }

  # Resolve ZIP file location
  cache_dir <- if (isTRUE(cache)) {
    tools::R_user_dir("fireR", "cache")
  } else if (isFALSE(cache)) {
    getwd()
  } else {
    as.character(cache)
  }

  zip_file <- fs::path(cache_dir, "mtbs_perimeter_data.zip")
  if (!fs::file_exists(zip_file)) {
    stop(
      "No MTBS ZIP file found in: ", cache_dir,
      "\nDownload it first with: get_mtbs(directory = \"", cache_dir, "\")"
    )
  }

  # Find shapefile inside ZIP
  zip_contents <- utils::unzip(zip_file, list = TRUE)
  shp_idx <- grep("\\.shp$", zip_contents$Name, ignore.case = TRUE)
  if (length(shp_idx) == 0L) stop("No .shp found in ZIP")
  shp_in_zip <- zip_contents$Name[[shp_idx[[1L]]]]
  shp_path <- sprintf(
    "/vsizip/%s/%s",
    normalizePath(zip_file, winslash = "/"),
    shp_in_zip
  )

  # Build SQL query
  layer <- tools::file_path_sans_ext(basename(shp_in_zip))
  where_clauses <- character(0)

  if (!is.null(years)) {
    where_clauses <- c(
      where_clauses,
      sprintf(
        "CAST(Ig_Date AS character(10)) >= '%04d-01-01' AND CAST(Ig_Date AS character(10)) <= '%04d-12-31'",
        years[1], years[2]
      )
    )
  }
  if (!is.null(type)) {
    type_eq <- paste(sprintf("Incid_Type = '%s'", type), collapse = " OR ")
    where_clauses <- c(where_clauses, sprintf("(%s)", type_eq))
  }
  sql_query <- if (length(where_clauses) > 0L) {
    sprintf(
      'SELECT * FROM "%s" WHERE %s',
      layer,
      paste(where_clauses, collapse = " AND ")
    )
  } else {
    NULL
  }

  # Read data
  if (verbose) cli::cli_inform("Reading {.path {basename(shp_in_zip)}} \u2026")
  data_sv <- if (!is.null(sql_query)) {
    terra::vect(shp_path, query = sql_query)
  } else {
    terra::vect(shp_path)
  }

  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}
