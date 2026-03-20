#' Download and unzip MTBS perimeter data
#'
#' Downloads the MTBS composite burned-area extent ZIP archive to a directory
#' and unzips it to \code{mtbs_perimeter_data/}. If data are already extracted
#' and \code{overwrite = FALSE}, no network call is made.
#'
#' @param url \code{character(1)} URL of the MTBS perimeter ZIP archive.
#' @param directory \code{character(1)} parent directory where
#'   \code{mtbs_perimeter_data.zip} and \code{mtbs_perimeter_data/} are stored.
#' @param overwrite \code{logical(1)} re-download and re-extract when
#'   \code{TRUE}. Defaults to \code{FALSE}.
#' @param retries \code{integer(1)} number of download retry attempts.
#' @param timeout \code{integer(1)} timeout in seconds for each download
#'   attempt.
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the extracted directory (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' mtbs_dir <- download_mtbs()
#' }
download_mtbs <- function(
    url = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    directory = getwd(),
    overwrite = FALSE,
    retries = 3L,
    timeout = 300L,
    verbose = TRUE
) {
  retries <- max(1L, as.integer(retries))
  timeout <- max(30L, as.integer(timeout))

  zip_file <- fs::path(directory, "mtbs_perimeter_data.zip")
  out_dir  <- fs::path(directory, "mtbs_perimeter_data")
  fs::dir_create(directory, recurse = TRUE)

  extracted <- fs::dir_exists(out_dir) && length(fs::dir_ls(out_dir, all = TRUE)) > 0L
  if (overwrite && extracted) {
    fs::dir_delete(out_dir)
    extracted <- FALSE
  }

  if (!extracted) {
    if (overwrite && fs::file_exists(zip_file)) {
      fs::file_delete(zip_file)
    }

    if (!fs::file_exists(zip_file)) {
      if (verbose) cli::cli_inform("Downloading MTBS perimeter data …")
      .download_zip(url, zip_file, retries = retries, timeout = timeout, verbose = verbose)
      if (verbose) cli::cli_inform("Download complete.")
    } else if (verbose) {
      cli::cli_inform("ZIP already exists: {.path {zip_file}}")
    }

    if (verbose) cli::cli_inform("Unzipping MTBS data …")
    utils::unzip(zip_file, exdir = out_dir, overwrite = TRUE)
    if (verbose) cli::cli_inform("Unzip complete.")
  } else if (verbose) {
    cli::cli_inform("MTBS data already extracted: {.path {out_dir}}")
  }

  invisible(as.character(out_dir))
}

#' Download MTBS perimeter data
#'
#' Convenience wrapper for [download_mtbs()].
#'
#' @inheritParams download_mtbs
#' @return \code{character(1)} path to the extracted directory (invisibly).
#' @export
get_mtbs <- function(
    url = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    directory = getwd(),
    overwrite = FALSE,
    retries = 3L,
    timeout = 300L,
    verbose = TRUE
) {
  download_mtbs(
    url = url,
    directory = directory,
    overwrite = overwrite,
    retries = retries,
    timeout = timeout,
    verbose = verbose
  )
}

#' Read MTBS fire perimeter data
#'
#' Reads MTBS fire perimeters from locally extracted data and returns either a
#' spatial object or a plain attribute table. Data are downloaded/unzipped via
#' [get_mtbs()] when needed.
#'
#' @param url \code{character(1)} URL of the MTBS perimeter ZIP archive.
#' @param years \code{integer} vector of length 1 or 2 specifying the year
#'   range to keep. If a single year is supplied, only fires from that year
#'   are returned. If two years are supplied they are treated as
#'   \code{c(start_year, end_year)} (inclusive). \code{NULL} (the default)
#'   returns all years without filtering.
#' @param type \code{character} vector of incident types to keep, matched
#'   against the \code{Incid_Type} column. Valid values are
#'   \code{"Wildfire"}, \code{"Prescribed Fire"}, \code{"Unknown"},
#'   \code{"Wildland Fire Use"}, and \code{"Complex"}. \code{NULL} (the
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
#'   (the default) data are downloaded/extracted in a per-session temporary
#'   directory. When \code{TRUE} data are cached in
#'   \code{tools::R_user_dir("fireR", "cache")}. Alternatively, supply a
#'   directory path as a string to control the location.
#' @param overwrite \code{logical(1)} force re-download and re-extraction.
#' @param retries \code{integer(1)} number of download retry attempts.
#' @param timeout \code{integer(1)} timeout in seconds per download attempt.
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
#' fires <- read_mtbs()
#' fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")
#' tbl <- read_mtbs(geometry = FALSE)
#' }
#' @export
read_mtbs <- function(
    url      = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    years    = NULL,
    type     = NULL,
    geometry = TRUE,
    output   = c("vect", "sf", "terra"),
    cache    = FALSE,
    overwrite = FALSE,
    retries  = 3L,
    timeout  = 300L,
    verbose  = TRUE
) {
  output <- rlang::arg_match(output)

  if (!is.null(years)) {
    years <- as.integer(years)
    if (length(years) == 1L) {
      years <- c(years, years)
    } else if (length(years) == 2L) {
      years <- sort(years)
    } else {
      cli::cli_abort(
        "{.arg years} must be a vector of length 1 or 2, not {length(years)}."
      )
    }
  }

  valid_types <- c("Wildfire", "Prescribed Fire", "Unknown",
                   "Wildland Fire Use", "Complex")
  if (!is.null(type)) {
    bad <- setdiff(type, valid_types)
    if (length(bad) > 0L) {
      cli::cli_abort(c(
        "Unknown {.arg type} value{?s}: {.val {bad}}.",
        "i" = "Must be one or more of: {.val {valid_types}}."
      ))
    }
  }

  if (!rlang::is_bool(geometry)) {
    cli::cli_abort("{.arg geometry} must be {.code TRUE} or {.code FALSE}.")
  }

  data_dir <- .resolve_download_dir(cache)
  mtbs_dir <- get_mtbs(
    url = url,
    directory = data_dir,
    overwrite = overwrite,
    retries = retries,
    timeout = timeout,
    verbose = verbose
  )

  shp_files <- list.files(mtbs_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
  if (length(shp_files) == 0L) {
    cli::cli_abort(c(
      "No {.file .shp} found inside {.path {mtbs_dir}}.",
      "i" = "The extracted data may be corrupt. Re-run with {.code overwrite = TRUE}."
    ))
  }

  shp_path <- shp_files[[1L]]

  layer         <- tools::file_path_sans_ext(basename(shp_path))
  where_clauses <- character(0)

  if (!is.null(years)) {
    start_date <- sprintf("%04d-01-01", years[[1L]])
    end_date   <- sprintf("%04d-12-31", years[[2L]])
    where_clauses <- c(
      where_clauses,
      sprintf("CAST(Ig_Date AS character(10)) >= '%s' AND CAST(Ig_Date AS character(10)) <= '%s'", start_date, end_date)
    )
  }

  if (!is.null(type)) {
    type_eq       <- paste(sprintf("Incid_Type = '%s'", type),
                           collapse = " OR ")
    where_clauses <- c(where_clauses, sprintf("(%s)", type_eq))
  }

  sql_query <- if (length(where_clauses) > 0L) {
    sprintf('SELECT * FROM "%s" WHERE %s', layer,
            paste(where_clauses, collapse = " AND "))
  } else {
    NULL
  }

  if (verbose) cli::cli_progress_step("Reading {.path {basename(shp_path)}} …")
  data_sv <- if (!is.null(sql_query)) {
    terra::vect(shp_path, query = sql_query)
  } else {
    terra::vect(shp_path)
  }
  if (verbose) cli::cli_progress_done()

  if (verbose && (!is.null(years) || !is.null(type))) {
    cli::cli_inform("Returned {nrow(data_sv)} fire perimeter{?s}.")
  }

  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}


# ── Internal helpers ──────────────────────────────────────────────────────────

#' @keywords internal
.resolve_download_dir <- function(cache) {
  if (isFALSE(cache)) {
    return(file.path(tempfile(pattern = "fireR_"), "dl"))
  }
  if (isTRUE(cache)) {
    return(tools::R_user_dir("fireR", "cache"))
  }
  as.character(cache)
}


#' @keywords internal
.download_zip <- function(url, dest, retries, timeout, verbose) {

  attempt <- 0L

  repeat {
    attempt <- attempt + 1L

    if (verbose) {
      cli::cli_progress_step(
        "Downloading MTBS perimeter data (attempt {attempt}/{retries}) …"
      )
    }

    # Remove partial file from a previous failed attempt
    if (fs::file_exists(dest)) fs::file_delete(dest)

    success <- tryCatch({
      curl::curl_download(
        url      = url,
        destfile = dest,
        quiet    = !verbose,
        handle   = curl::new_handle(
          http_version   = 2L,
          tcp_keepalive  = 1L,
          followlocation = 1L,
          ssl_verifypeer = 1L,
          timeout        = timeout,
          connecttimeout = 30L,
          low_speed_limit = 1000L,
          low_speed_time  = 30L
        )
      )
      TRUE
    }, error = function(e) {
      if (verbose) {
        cli::cli_warn(c(
          "!" = "Attempt {attempt} failed: {conditionMessage(e)}"
        ))
      }
      FALSE
    })

    if (isTRUE(success)) {
      if (verbose) cli::cli_progress_done()
      return(invisible(dest))
    }

    if (attempt >= retries) {
      cli::cli_abort(c(
        "Download failed after {retries} attempt{?s}.",
        "i" = "URL: {.url {url}}",
        "i" = "Try {.code cache = TRUE} and {.code retries = 5L}, or check your connection."
      ))
    }

    if (verbose) cli::cli_inform("Retrying in 5 seconds …")
    Sys.sleep(5)
  }
}
