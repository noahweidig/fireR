#' Download and unzip NIFC wildfire data
#'
#' Downloads the NIFC (National Interagency Fire Center) wildfire perimeters
#' dataset from figshare and unzips it to a local directory.  If the ZIP
#' already exists and \code{overwrite = FALSE}, no network call is made.
#'
#' @param directory \code{character(1)} directory where the ZIP file and
#'   unzipped contents are stored.  Defaults to the current working directory.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the downloaded ZIP file (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' zip_path <- get_nifc()
#' zip_path <- get_nifc(directory = "data/nifc")
#' }
get_nifc <- function(
    directory = getwd(),
    overwrite = FALSE,
    verbose   = TRUE
) {
  url      <- "https://ndownloader.figshare.com/files/38766504"
  zip_name <- "nifc_perimeters.zip"
  zip_file <- fs::path(directory, zip_name)

  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  did_download <- FALSE
  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading NIFC wildfire perimeters ...")
    curl::curl_download(url, destfile = zip_file,
                        handle = curl::new_handle(followlocation = TRUE, useragent = .ua_string),
                        quiet  = FALSE)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
    did_download <- TRUE
  } else if (verbose) {
    cli::cli_inform("NIFC ZIP already exists: {.path {zip_file}}")
  }

  if (did_download) {
    if (verbose) cli::cli_inform("Unzipping {.path {zip_file}} ...")
    utils::unzip(zip_file, exdir = directory)
    if (verbose) cli::cli_inform("Unzip complete: {.path {directory}}")
  }

  invisible(zip_file)
}

#' Download and unzip USFS Fire Occurrence Database (FOD)
#'
#' Downloads the USFS Fire Occurrence Database (FPA-FOD) GeoPackage ZIP
#' archive from the Forest Service Research Data Archive and unzips it to a
#' local directory.  The server requires browser-like request headers, so
#' \pkg{httr2} is used instead of a simple download helper.  If the ZIP
#' already exists and \code{overwrite = FALSE}, no network call is made.
#'
#' @param directory \code{character(1)} directory where the ZIP file and
#'   unzipped contents are stored.  Defaults to the current working directory.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the downloaded ZIP file (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' zip_path <- get_fod()
#' zip_path <- get_fod(directory = "data/fod")
#' }
get_fod <- function(
    directory = getwd(),
    overwrite = FALSE,
    verbose   = TRUE
) {
  url      <- "https://www.fs.usda.gov/rds/archive/products/RDS-2013-0009.6/RDS-2013-0009.6_Data_Format3_GPKG.zip"
  zip_name <- "RDS-2013-0009.6_Data_Format3_GPKG.zip"
  zip_file <- fs::path(directory, zip_name)

  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  did_download <- FALSE
  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading USFS Fire Occurrence Database (FOD) ...")
    req <- httr2::request(url)
    req <- httr2::req_headers(
      req,
      "User-Agent" = .ua_string,
      "Accept"     = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Referer"    = "https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0009.6"
    )
    req <- httr2::req_timeout(req, 3600)
    httr2::req_perform(req, path = zip_file)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
    did_download <- TRUE
  } else if (verbose) {
    cli::cli_inform("FOD ZIP already exists: {.path {zip_file}}")
  }

  if (did_download) {
    if (verbose) cli::cli_inform("Unzipping {.path {zip_file}} ...")
    utils::unzip(zip_file, exdir = directory)
    if (verbose) cli::cli_inform("Unzip complete: {.path {directory}}")
  }

  invisible(zip_file)
}

#' Read NIFC wildfire perimeter data
#'
#' Reads NIFC wildfire perimeters from a local NIFC ZIP downloaded with
#' [get_nifc()] and returns either a spatial object or a plain attribute table.
#'
#' `read_nifc()` does not download data. Use [get_nifc()] first to obtain the
#' perimeters ZIP archive.
#'
#' The ZIP is expected to contain either a GeoPackage (\code{.gpkg}) or a
#' shapefile (\code{.shp}).  Year filtering uses the integer \code{FireYear}
#' column present in the NIFC historical perimeters data.
#'
#' @param years \code{integer} vector of years to keep.  Accepts a single
#'   year (\code{2020}), a contiguous range created with \code{:} notation
#'   (\code{2010:2020}), or a vector of specific years
#'   (\code{c(2000, 2010, 2020)}).  Only fires whose \code{FireYear} appears in
#'   \code{years} are returned.  \code{NULL} (the default) returns all years
#'   without filtering.
#' @param geometry \code{logical(1)} When \code{TRUE} (the default) the result
#'   is a spatial object (\code{sf} or \code{terra::SpatVector} depending on
#'   \code{output}).  When \code{FALSE} the attributes are returned as a plain
#'   \code{data.frame}.
#' @param output \code{character(1)} The class of the returned spatial object.
#'   Either \code{"vect"} / \code{"terra"} (default) for a
#'   \code{terra::SpatVector}, or \code{"sf"} for an \code{sf} object.
#'   Ignored when \code{geometry = FALSE}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where
#'   \code{read_nifc()} looks for the downloaded ZIP file.  When \code{FALSE}
#'   (the default), the current working directory is used.  When \code{TRUE},
#'   the platform user cache directory
#'   (\code{tools::R_user_dir("fireR", "cache")}) is used.  Supply a directory
#'   path as a string to specify a custom location.
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
#' zip_path <- get_nifc()
#' perims <- read_nifc(output = "sf")
#'
#' # Single year
#' perims_2020 <- read_nifc(years = 2020, output = "sf")
#'
#' # Contiguous range
#' perims_recent <- read_nifc(years = 2015:2020, output = "sf")
#'
#' # Specific years only
#' perims_sel <- read_nifc(years = c(2010, 2015, 2020), output = "sf")
#'
#' # Attribute table only (no geometry)
#' tbl <- read_nifc(geometry = FALSE)
#' }
#' @export
read_nifc <- function(
    years    = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    cache    = FALSE,
    verbose  = TRUE
) {
  output <- rlang::arg_match(output)

  if (!is.logical(geometry) || length(geometry) != 1L || is.na(geometry)) {
    stop("`geometry` must be TRUE or FALSE")
  }

  if (!is.null(years)) {
    if (!is.numeric(years) || length(years) == 0L || any(is.na(years))) {
      stop("`years` must be a non-empty integer vector with no NA values")
    }
    years <- as.integer(years)
    years <- sort(unique(years))
  }

  if ((!is.logical(cache) && !is.character(cache)) || length(cache) != 1L || is.na(cache)) {
    stop("`cache` must be a single logical or character value")
  }

  cache_dir <- if (isTRUE(cache)) {
    tools::R_user_dir("fireR", "cache")
  } else if (isFALSE(cache)) {
    getwd()
  } else {
    as.character(cache)
  }

  zip_file <- fs::path(cache_dir, "nifc_perimeters.zip")
  if (!fs::file_exists(zip_file)) {
    stop(
      "No NIFC ZIP file found in: ", cache_dir,
      "\nDownload it first with: get_nifc(directory = \"", cache_dir, "\")"
    )
  }

  # Find the data file inside the ZIP - prefer .gpkg, then .shp, then .gdb.
  zip_contents <- utils::unzip(zip_file, list = TRUE)
  gpkg_idx <- grep("\\.gpkg$", zip_contents$Name, ignore.case = TRUE)
  shp_idx  <- grep("\\.shp$",  zip_contents$Name, ignore.case = TRUE)
  gdb_idx  <- grep("\\.gdb(/|$)", zip_contents$Name, ignore.case = TRUE)

  data_path <- NULL
  data_in_zip <- NULL
  is_gpkg <- length(gpkg_idx) > 0L
  is_gdb <- FALSE

  if (is_gpkg) {
    data_in_zip <- zip_contents$Name[[gpkg_idx[[1L]]]]
  } else if (length(shp_idx) > 0L) {
    data_in_zip <- zip_contents$Name[[shp_idx[[1L]]]]
  } else if (length(gdb_idx) > 0L) {
    data_in_zip <- sub("(.*\\.gdb).*", "\\1", zip_contents$Name[[gdb_idx[[1L]]]], ignore.case = TRUE)
    is_gdb <- TRUE
  }

  if (!is.null(data_in_zip)) {
    data_path <- sprintf(
      "/vsizip/%s/%s",
      normalizePath(zip_file, winslash = "/"),
      data_in_zip
    )
  } else {
    gpkg_files <- list.files(cache_dir, pattern = "\\.gpkg$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
    shp_files <- list.files(cache_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
    gdb_files <- list.files(cache_dir, pattern = "\\.gdb$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)

    if (length(gpkg_files) > 0L) {
      data_path <- normalizePath(gpkg_files[[1L]], winslash = "/")
      is_gpkg <- TRUE
    } else if (length(shp_files) > 0L) {
      data_path <- normalizePath(shp_files[[1L]], winslash = "/")
    } else if (length(gdb_files) > 0L) {
      data_path <- normalizePath(gdb_files[[1L]], winslash = "/")
      is_gdb <- TRUE
    } else {
      stop("No .gpkg, .shp, or .gdb file found in the NIFC download")
    }
  }

  # Determine layer name - required for the SQL query
  layer <- if (is_gpkg || is_gdb) {
    sf::st_layers(data_path)$name[[1L]]
  } else if (!is.null(data_in_zip)) {
    tools::file_path_sans_ext(basename(data_in_zip))
  } else {
    tools::file_path_sans_ext(basename(data_path))
  }

  # FireYear is an integer column in NIFC historical perimeter data
  sql_query <- if (!is.null(years)) {
    sprintf(
      'SELECT * FROM "%s" WHERE "FireYear" IN (%s)',
      layer,
      paste(years, collapse = ", ")
    )
  } else {
    NULL
  }

  if (verbose) cli::cli_inform("Reading NIFC wildfire perimeters ...")
  data_sv <- if (is_gpkg || is_gdb) {
    if (!is.null(sql_query)) {
      terra::vect(data_path, layer = layer, query = sql_query)
    } else {
      terra::vect(data_path, layer = layer)
    }
  } else {
    if (!is.null(sql_query)) {
      terra::vect(data_path, query = sql_query)
    } else {
      terra::vect(data_path)
    }
  }

  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}

#' Read USFS Fire Occurrence Database (FOD) data
#'
#' Reads the USFS Fire Occurrence Database (FPA-FOD) from a local ZIP
#' downloaded with [get_fod()] and returns either a spatial object or a plain
#' attribute table.
#'
#' `read_fod()` does not download data.  Use [get_fod()] first to obtain the
#' GeoPackage ZIP archive.
#'
#' The ZIP contains a GeoPackage with a single \code{Fires} layer covering
#' 1992--2020.  Year filtering uses the integer \code{FIRE_YEAR} column.
#'
#' @param years \code{integer} vector of years to keep.  Accepts a single
#'   year (\code{2015}), a contiguous range created with \code{:} notation
#'   (\code{2010:2020}), or a vector of specific years
#'   (\code{c(2000, 2010, 2020)}).  Only fires whose \code{FIRE_YEAR} appears
#'   in \code{years} are returned.  \code{NULL} (the default) returns all
#'   years without filtering.
#' @param geometry \code{logical(1)} When \code{TRUE} (the default) the result
#'   is a spatial object (\code{sf} or \code{terra::SpatVector} depending on
#'   \code{output}).  When \code{FALSE} the attributes are returned as a plain
#'   \code{data.frame}.
#' @param output \code{character(1)} The class of the returned spatial object.
#'   Either \code{"vect"} / \code{"terra"} (default) for a
#'   \code{terra::SpatVector}, or \code{"sf"} for an \code{sf} object.
#'   Ignored when \code{geometry = FALSE}.
#' @param cache \code{logical(1)} or \code{character(1)}.  Controls where
#'   \code{read_fod()} looks for the downloaded ZIP file.  When \code{FALSE}
#'   (the default), the current working directory is used.  When \code{TRUE},
#'   the platform user cache directory
#'   (\code{tools::R_user_dir("fireR", "cache")}) is used.  Supply a directory
#'   path as a string to specify a custom location.
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
#' zip_path <- get_fod()
#' fires <- read_fod(output = "sf")
#'
#' # Single year
#' fires_2015 <- read_fod(years = 2015, output = "sf")
#'
#' # Range of years
#' fires_recent <- read_fod(years = 2015:2020, output = "sf")
#'
#' # Specific years only
#' fires_sel <- read_fod(years = c(2000, 2010, 2020), output = "sf")
#'
#' # Attribute table only (no geometry)
#' tbl <- read_fod(geometry = FALSE)
#' }
#' @export
read_fod <- function(
    years    = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    cache    = FALSE,
    verbose  = TRUE
) {
  output <- rlang::arg_match(output)

  if (!is.logical(geometry) || length(geometry) != 1L || is.na(geometry)) {
    stop("`geometry` must be TRUE or FALSE")
  }

  if (!is.null(years)) {
    if (!is.numeric(years) || length(years) == 0L || any(is.na(years))) {
      stop("`years` must be a non-empty integer vector with no NA values")
    }
    years <- as.integer(years)
    years <- sort(unique(years))
  }

  if ((!is.logical(cache) && !is.character(cache)) || length(cache) != 1L || is.na(cache)) {
    stop("`cache` must be a single logical or character value")
  }

  cache_dir <- if (isTRUE(cache)) {
    tools::R_user_dir("fireR", "cache")
  } else if (isFALSE(cache)) {
    getwd()
  } else {
    as.character(cache)
  }

  zip_name <- "RDS-2013-0009.6_Data_Format3_GPKG.zip"
  zip_file <- fs::path(cache_dir, zip_name)
  if (!fs::file_exists(zip_file)) {
    stop(
      "No FOD ZIP file found in: ", cache_dir,
      "\nDownload it first with: get_fod(directory = \"", cache_dir, "\")"
    )
  }

  # Find the GeoPackage inside the ZIP
  zip_contents <- utils::unzip(zip_file, list = TRUE)
  gpkg_idx <- grep("\\.gpkg$", zip_contents$Name, ignore.case = TRUE)
  if (length(gpkg_idx) == 0L) stop("No .gpkg file found in the FOD ZIP")
  gpkg_in_zip <- zip_contents$Name[[gpkg_idx[[1L]]]]

  gpkg_path <- sprintf(
    "/vsizip/%s/%s",
    normalizePath(zip_file, winslash = "/"),
    gpkg_in_zip
  )

  # The FOD GeoPackage has a single layer named "Fires" with an integer
  # FIRE_YEAR column covering 1992-2020
  layer <- "Fires"

  sql_query <- if (!is.null(years)) {
    sprintf(
      'SELECT * FROM "%s" WHERE "FIRE_YEAR" IN (%s)',
      layer,
      paste(years, collapse = ", ")
    )
  } else {
    NULL
  }

  if (verbose) cli::cli_inform("Reading FPA-FOD fire occurrence data ...")
  data_sv <- if (!is.null(sql_query)) {
    terra::vect(gpkg_path, layer = layer, query = sql_query)
  } else {
    terra::vect(gpkg_path, layer = layer)
  }

  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}
