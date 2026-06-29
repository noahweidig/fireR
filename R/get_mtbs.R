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
#' @param dry_run \code{logical(1)} if \code{TRUE}, do not download the file but instead return the path where it would be saved. Defaults to \code{FALSE}.
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
    verbose   = TRUE,
    dry_run   = FALSE
) {
  dataset <- rlang::arg_match(dataset)

  if (!is.character(directory) || length(directory) != 1L || is.na(directory)) {
    stop("`directory` must be a single character string")
  }
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    stop("`overwrite` must be TRUE or FALSE")
  }
  if (!is.numeric(timeout) || length(timeout) != 1L || is.na(timeout) || timeout <= 0) {
    stop("`timeout` must be a single positive number")
  }
  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE")
  }
  if (!is.logical(dry_run) || length(dry_run) != 1L || is.na(dry_run)) {
    stop("`dry_run` must be TRUE or FALSE")
  }

  if (dataset == "occurrence") {
    url      <- "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/fod_pt_shapefile/mtbs_fod_pts_data.zip"
    zip_name <- "mtbs_fod_pts_data.zip"
  } else {
    url      <- "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip"
    zip_name <- "mtbs_perimeter_data.zip"
  }

  zip_file <- fs::path(directory, zip_name)

  if (dry_run) {
    if (verbose) cli::cli_inform("Dry run: Would download MTBS {dataset} data to {.path {zip_file}}")
    return(invisible(zip_file))
  }

  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  if (!fs::file_exists(zip_file)) {
    cli::cli_warn(c("!" = "This is a large download (hundreds of megabytes)."))
    if (verbose) cli::cli_inform("Downloading MTBS {dataset} data \u2026")
    handle <- curl::new_handle(
      followlocation = TRUE,
      useragent      = .ua_string,
      timeout        = as.integer(timeout)
    )
    curl::curl_download(url, destfile = zip_file, handle = handle, quiet = !verbose)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("MTBS ZIP already exists: {.path {zip_file}}")
  }

  invisible(zip_file)
}

#' Read MTBS fire perimeter or occurrence data
#'
#' Reads MTBS fire data from a local MTBS ZIP downloaded with
#' [get_mtbs()] and returns either a spatial object or a plain attribute table.
#'
#' `read_mtbs()` does not download data. Use [get_mtbs()] first to obtain the
#' data ZIP archive.
#'
#' @param dataset \code{character(1)} which dataset to read. Use
#'   \code{"perimeters"} (default) to read fire perimeters as polygons, or
#'   \code{"occurrence"} to read fire centroids as points.
#' @param years \code{integer} vector of years to keep.  Accepts a single
#'   year (\code{2020}), a contiguous range created with \code{:} notation
#'   (\code{2010:2023}), or a vector of specific years
#'   (\code{c(2000, 2010, 2020)}).  Only fires whose ignition year appears in
#'   \code{years} are returned.  \code{NULL} (the default) returns all years
#'   without filtering.
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
#'   (the default), the current working directory is used (it does not mean
#'   caching is disabled, just that it looks in the local folder). When
#'   \code{TRUE}, the platform user cache directory
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
#'
#' # Single year
#' fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")
#'
#' # Contiguous range
#' fires_recent <- read_mtbs(years = 2010:2023, output = "sf")
#'
#' # Specific years only
#' fires_sel <- read_mtbs(years = c(2010, 2015, 2020), output = "sf")
#'
#' tbl <- read_mtbs(geometry = FALSE)
#' }
#' @export
read_mtbs <- function(
    dataset  = c("perimeters", "occurrence"),
    years    = NULL,
    type     = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    cache    = FALSE,
    verbose  = TRUE
) {
  dataset <- rlang::arg_match(dataset)
  output  <- rlang::arg_match(output)

  if (!is.logical(verbose) || length(verbose) != 1L || is.na(verbose)) {
    stop("`verbose` must be TRUE or FALSE")
  }

  # Validate geometry
  if (!is.logical(geometry) || length(geometry) != 1L || is.na(geometry)) {
    stop("`geometry` must be TRUE or FALSE")
  }

  # Validate years
  if (!is.null(years)) {
    if (!is.numeric(years) || length(years) == 0L || any(is.na(years)) || any(years %% 1 != 0)) {
      stop("`years` must be a non-empty integer vector with no NA values")
    }
    years <- as.integer(years)
    years <- sort(unique(years))
  }

  # Validate types
  valid_types <- c("Wildfire", "Prescribed Fire", "Unknown", "Wildland Fire Use")
  if (!is.null(type)) {
    if (!is.character(type) || length(type) == 0L || any(is.na(type))) {
      stop("`type` must be a non-empty character vector with no NA values")
    }
    bad <- setdiff(type, valid_types)
    if (length(bad) > 0L) stop("Unknown type: ", paste(bad, collapse = ", "))
  }

  # Validate cache
  if ((!is.logical(cache) && !is.character(cache)) || length(cache) != 1L || is.na(cache)) {
    stop("`cache` must be a single logical or character value")
  }

  # Resolve ZIP file location
  cache_dir <- if (isTRUE(cache)) {
    tools::R_user_dir("fireR", "cache")
  } else if (isFALSE(cache)) {
    getwd()
  } else {
    as.character(cache)
  }

  if (dataset == "occurrence") {
    zip_name <- "mtbs_fod_pts_data.zip"
  } else {
    zip_name <- "mtbs_perimeter_data.zip"
  }

  zip_file <- fs::path(cache_dir, zip_name)
  if (!fs::file_exists(zip_file)) {
    stop(
      "No MTBS ZIP file found in: ", cache_dir,
      "\nDownload it first with: get_mtbs(dataset = \"", dataset, "\", directory = \"", cache_dir, "\")"
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
    year_strs <- paste(sprintf("'%04d'", years), collapse = ", ")
    where_clauses <- c(
      where_clauses,
      sprintf("substr(CAST(Ig_Date AS character), 1, 4) IN (%s)", year_strs)
    )
  }
  if (!is.null(type)) {
    type <- unique(type)
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
