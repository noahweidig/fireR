#' Download and Load MTBS Fire Perimeter Data
#'
#' Downloads the MTBS composite burned-area extent shapefile from the USGS,
#' unzips it, and returns fire perimeters as a spatial object. Downloads are
#' performed using `curl`'s multi-handle for maximum throughput.
#'
#' @param url `character(1)` URL of the MTBS perimeter ZIP archive.
#'   Defaults to the official USGS composite data endpoint.
#' @param years `integer` vector of length 1 or 2 specifying the year range
#'   to keep. If a single year is supplied, only fires from that year are
#'   returned. If two years are supplied they are treated as
#'   `c(start_year, end_year)` (inclusive). `NULL` (the default) returns all
#'   years without filtering.
#' @param return_spatial `logical(1)` When `TRUE` (the default) the result is
#'   a spatial object (`sf` or `terra::SpatVector` depending on `output`).
#'   When `FALSE` the shapefile attributes are returned as a plain
#'   `data.frame` with the geometry column dropped.
#' @param output `character(1)` The class of the returned spatial object.
#'   Either `"sf"` (default) or `"vect"` / `"terra"` for a `terra::SpatVector`.
#'   Ignored when `return_spatial = FALSE`.
#' @param cache `logical(1)` or `character(1)`. When `FALSE` (the default)
#'   the ZIP is downloaded to a per-session temporary directory and deleted
#'   when the R session ends. When `TRUE` the file is cached in
#'   `tools::R_user_dir("fireR", "cache")` so subsequent calls skip the
#'   download entirely. Alternatively, supply a directory path as a string
#'   to control the cache location yourself.
#' @param overwrite `logical(1)` When `cache` is enabled, set `TRUE` to
#'   force a fresh download even if a cached copy exists. Defaults to `FALSE`.
#' @param verbose `logical(1)` Print progress messages. Defaults to `TRUE`.
#'
#' @return
#'   * An `sf` object when `output = "sf"` and `return_spatial = TRUE`.
#'   * A `terra::SpatVector` when `output = "vect"` / `"terra"` and
#'     `return_spatial = TRUE`.
#'   * A `data.frame` when `return_spatial = FALSE`.
#'
#' @details
#' ## Speed
#' `curl::curl_download()` is used in preference to base `download.file()`
#' because the `curl` back-end uses a persistent HTTP/2 connection and avoids
#' the overhead of spawning an external process. For very large files you can
#' squeeze out additional throughput by setting the `CURL_CA_BUNDLE`
#' environment variable to point at a local CA bundle so TLS handshakes are
#' faster.
#'
#' ## Year filtering
#' Filtering is applied to the `Year` column that MTBS includes in the
#' attribute table. If the column cannot be found the raw data are returned
#' with a warning.
#'
#' @examples
#' \dontrun{
#' # Default: all years, return as sf
#' fires <- get_mtbs()
#'
#' # Only fires from 2020 to 2023, as a terra SpatVector
#' fires_recent <- get_mtbs(years = c(2020, 2023), output = "vect")
#'
#' # Single year
#' fires_2020 <- get_mtbs(years = 2020)
#'
#' # Attribute table only (no geometry)
#' tbl <- get_mtbs(return_spatial = FALSE)
#'
#' # Cache the download for future sessions
#' fires <- get_mtbs(cache = TRUE)
#' }
#'
#' @export
get_mtbs <- function(
    url          = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    years        = NULL,
    return_spatial = TRUE,
    output       = c("sf", "vect", "terra"),
    cache        = FALSE,
    overwrite    = FALSE,
    verbose      = TRUE
) {

  # ── Argument validation ────────────────────────────────────────────────────
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

  if (!rlang::is_bool(return_spatial)) {
    cli::cli_abort("{.arg return_spatial} must be {.code TRUE} or {.code FALSE}.")
  }

  # ── Resolve download destination ───────────────────────────────────────────
  zip_path <- .resolve_cache(url, cache, overwrite, verbose)

  # ── Download ───────────────────────────────────────────────────────────────
  if (!fs::file_exists(zip_path)) {
    .download_fast(url, zip_path, verbose)
  } else {
    if (verbose) {
      cli::cli_inform(
        "c" = "Using cached file: {.path {zip_path}}"
      )
    }
  }

  # ── Unzip ──────────────────────────────────────────────────────────────────
  exdir <- fs::path(fs::path_dir(zip_path), "mtbs_unzipped")
  fs::dir_create(exdir)

  if (verbose) cli::cli_progress_step("Unzipping archive \u2026")
  utils::unzip(zip_path, exdir = exdir, overwrite = TRUE)
  if (verbose) cli::cli_progress_done()

  # ── Locate the shapefile ───────────────────────────────────────────────────
  shp_files <- fs::dir_ls(exdir, recurse = TRUE, glob = "*.shp")

  if (length(shp_files) == 0L) {
    cli::cli_abort(
      "No {.file .shp} file found after unzipping. \\
      Check that {.url {url}} returns a valid shapefile ZIP."
    )
  }

  # Prefer a file with "perimeter" in the name if there are multiple
  perimeter_shp <- shp_files[grepl("perimeter", basename(shp_files), ignore.case = TRUE)]
  shp_path <- if (length(perimeter_shp) >= 1L) perimeter_shp[[1L]] else shp_files[[1L]]

  if (verbose) cli::cli_inform("Reading {.path {basename(shp_path)}} \u2026")

  # ── Read shapefile ─────────────────────────────────────────────────────────
  data_sf <- sf::st_read(shp_path, quiet = !verbose)

  # ── Year filtering ─────────────────────────────────────────────────────────
  if (!is.null(years)) {
    data_sf <- .filter_years(data_sf, years, verbose)
  }

  # ── Return ─────────────────────────────────────────────────────────────────
  if (!return_spatial) {
    return(sf::st_drop_geometry(data_sf))
  }

  if (output == "sf") {
    return(data_sf)
  }

  # terra::SpatVector
  terra::vect(data_sf)
}


# ── Internal helpers ──────────────────────────────────────────────────────────

#' @keywords internal
.resolve_cache <- function(url, cache, overwrite, verbose) {
  file_name <- basename(url)

  if (isFALSE(cache)) {
    # Session-scoped temp dir (auto-cleaned on exit)
    tmp_dir  <- fs::path(withr::local_tempdir(pattern = "fireR_"), "dl")
    fs::dir_create(tmp_dir)
    zip_path <- fs::path(tmp_dir, file_name)

    # Always re-download for session temp usage
    return(zip_path)
  }

  # Persistent cache directory
  cache_dir <- if (isTRUE(cache)) {
    fs::path(tools::R_user_dir("fireR", "cache"))
  } else {
    fs::path(cache)  # user-supplied path
  }

  fs::dir_create(cache_dir, recurse = TRUE)
  zip_path <- fs::path(cache_dir, file_name)

  if (overwrite && fs::file_exists(zip_path)) {
    if (verbose) cli::cli_inform("Removing cached copy for fresh download.")
    fs::file_delete(zip_path)
  }

  zip_path
}


#' @keywords internal
.download_fast <- function(url, dest, verbose) {
  if (verbose) {
    cli::cli_progress_step(
      "Downloading MTBS perimeter data ({.url {url}}) \u2026"
    )
  }

  tryCatch(
    curl::curl_download(
      url      = url,
      destfile = dest,
      quiet    = !verbose,
      # Use HTTP/2 multiplexing and keep-alive where available
      handle   = curl::new_handle(
        http_version  = 2L,   # CURL_HTTP_VERSION_2 (falls back to 1.1)
        tcp_keepalive = 1L,
        followlocation = 1L,
        ssl_verifypeer = 1L
      )
    ),
    error = function(e) {
      cli::cli_abort(
        c(
          "Download failed.",
          "i" = "URL: {.url {url}}",
          "x" = conditionMessage(e)
        )
      )
    }
  )

  if (verbose) cli::cli_progress_done()
  invisible(dest)
}


#' @keywords internal
.filter_years <- function(data_sf, years, verbose) {
  # MTBS column names are not always consistent across releases; try several
  year_col <- intersect(
    c("Year", "YEAR", "year", "BurnBndLat", "Ig_Date"),
    names(data_sf)
  )

  # "Ig_Date" is an ignition-date column — extract year from it
  if (length(year_col) == 0L) {
    cli::cli_warn(
      "Could not locate a year column in the MTBS attribute table. \\
      Returning unfiltered data."
    )
    return(data_sf)
  }

  col <- year_col[[1L]]

  if (col == "Ig_Date") {
    # Ig_Date is typically stored as a date or character "YYYY/MM/DD"
    yr_vec <- as.integer(
      format(as.Date(as.character(data_sf[[col]]), tryFormats = c("%Y/%m/%d", "%Y-%m-%d")), "%Y")
    )
  } else {
    yr_vec <- as.integer(data_sf[[col]])
  }

  keep <- !is.na(yr_vec) & yr_vec >= years[[1L]] & yr_vec <= years[[2L]]

  if (verbose) {
    n_kept  <- sum(keep)
    n_total <- nrow(data_sf)
    cli::cli_inform(
      "Kept {n_kept} of {n_total} fire perimeters \\
      ({years[[1L]]}\u2013{years[[2L]]})."
    )
  }

  data_sf[keep, ]
}
