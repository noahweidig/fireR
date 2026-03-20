#' Download and Load MTBS Fire Perimeter Data
#'
#' Downloads the MTBS composite burned-area extent shapefile from the USGS,
#' unzips it, and returns fire perimeters as a spatial object. The shapefile
#' is read via `terra` (significantly faster than `sf` for large files) and
#' converted to `sf` only when requested. Year and type filtering is performed
#' via an OGR SQL query so only matching features are read into memory.
#'
#' @param url `character(1)` URL of the MTBS perimeter ZIP archive.
#'   Defaults to the official USGS composite data endpoint.
#' @param years `integer` vector of length 1 or 2 specifying the year range
#'   to keep. If a single year is supplied, only fires from that year are
#'   returned. If two years are supplied they are treated as
#'   `c(start_year, end_year)` (inclusive). `NULL` (the default) returns all
#'   years without filtering. Filtering is based on the `Ig_Date` column
#'   (format `YYYY-MM-DD`) via OGR SQL.
#' @param type `character` vector of incident types to keep, matched against
#'   the `Incid_Type` column. Valid values are `"Wildfire"`,
#'   `"Prescribed Fire"`, `"Unknown"`, `"Wildland Fire Use"`, and
#'   `"Complex"`. `NULL` (the default) returns all incident types.
#' @param geometry `logical(1)` When `TRUE` (the default) the result is
#'   a spatial object (`sf` or `terra::SpatVector` depending on `output`).
#'   When `FALSE` the shapefile attributes are returned as a plain
#'   `data.frame` with the geometry column dropped.
#' @param output `character(1)` The class of the returned spatial object.
#'   Either `"vect"` / `"terra"` (default) for a `terra::SpatVector`, or
#'   `"sf"` for an `sf` object. Defaulting to `"vect"` avoids the overhead
#'   of converting to `sf` when it is not needed. Ignored when
#'   `geometry = FALSE`.
#' @param cache `logical(1)` or `character(1)`. When `FALSE` (the default)
#'   the ZIP is downloaded to a per-session temporary directory and deleted
#'   when the R session ends. When `TRUE` the file is cached in
#'   `tools::R_user_dir("fireR", "cache")` so subsequent calls skip the
#'   download entirely. Alternatively, supply a directory path as a string
#'   to control the cache location yourself.
#' @param overwrite `logical(1)` When `cache` is enabled, set `TRUE` to
#'   force a fresh download even if a cached copy exists. Defaults to `FALSE`.
#' @param verbose `logical(1)` Print progress messages. Defaults to `TRUE`.
#' @param method `character(1)` Download back-end. `"curl"` (default) uses
#'   `curl::curl_download()` with an HTTP/2 persistent connection. `"wget"`
#'   delegates to the system `wget` executable via `download.file()` and may
#'   be faster on systems where `wget` is installed and tuned. Falls back to
#'   `"curl"` with a warning if `wget` is not found on `PATH`.
#' @param background `logical(1)` When `TRUE` the download (and all
#'   subsequent processing) runs in a background R process via
#'   `callr::r_bg()`, so your interactive session stays responsive.
#'   The function returns a `callr` process object immediately; call
#'   `$wait()` to block until it finishes and `$get_result()` to retrieve
#'   the spatial object. Requires the \pkg{callr} package. Defaults to
#'   `FALSE`.
#'
#' @return
#'   * When `background = FALSE` (default):
#'     * A `terra::SpatVector` when `output = "vect"` / `"terra"` and
#'       `geometry = TRUE`.
#'     * An `sf` object when `output = "sf"` and `geometry = TRUE`.
#'     * A `data.frame` when `geometry = FALSE`.
#'   * When `background = TRUE`: a `callr` `r_process` object. Use
#'     `$wait()` then `$get_result()` to obtain the spatial object.
#'
#' @details
#' ## Speed
#' Three design decisions keep this function fast:
#'
#' 1. **`terra::SpatVector` is the default output** (`output = "vect"`).
#'    The `terra` C++ layer reads shapefiles substantially faster than
#'    `sf::st_read()`, and skipping the `sf::st_as_sf()` conversion saves
#'    additional time. Pass `output = "sf"` explicitly when you need an
#'    `sf` object.
#'
#' 2. **`curl::curl_download()`** is used in preference to base
#'    `download.file()` because the `curl` back-end uses a persistent HTTP/2
#'    connection, avoids spawning an external process, and never times out on
#'    large files (the handle is configured with `timeout = 0`).
#'    Pass `method = "wget"` to delegate to the system `wget` instead.
#'
#' 3. **OGR SQL filtering** is applied at read time via `terra::vect()`, so
#'    only matching features are loaded into memory.
#'
#' ## Non-blocking download
#' Pass `background = TRUE` to keep your R session responsive while the
#' ~100 MB archive downloads:
#'
#' ```r
#' proc <- get_mtbs(years = 2020, background = TRUE)
#' # … do other work …
#' proc$wait()
#' fires <- proc$get_result()
#' ```
#'
#' `background = TRUE` requires the \pkg{callr} package
#' (`install.packages("callr")`).
#'
#' ## Year and type filtering
#' Filtering is performed as an OGR SQL `WHERE` clause passed directly to
#' `terra::vect()`, so only matching features are read into memory. Years are
#' matched against the `Ig_Date` column (e.g. `1997-04-23`); incident types
#' are matched against the `Incid_Type` column.
#'
#' @examples
#' \dontrun{
#' # Default: all years, return as terra SpatVector (fastest)
#' fires <- get_mtbs()
#'
#' # Only fires from 2020 to 2023
#' fires_recent <- get_mtbs(years = c(2020, 2023))
#'
#' # Single year, wildfires only, as sf
#' fires_2020 <- get_mtbs(years = 2020, type = "Wildfire", output = "sf")
#'
#' # Attribute table only (no geometry)
#' tbl <- get_mtbs(geometry = FALSE)
#'
#' # Cache the download for future sessions
#' fires <- get_mtbs(cache = TRUE)
#'
#' # Non-blocking: download in background, keep working
#' proc <- get_mtbs(years = 2020, background = TRUE)
#' proc$wait()
#' fires <- proc$get_result()
#'
#' # Use system wget instead of curl
#' fires <- get_mtbs(method = "wget")
#' }
#'
#' @export
get_mtbs <- function(
    url          = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    years        = NULL,
    type         = NULL,
    geometry     = TRUE,
    output       = c("vect", "sf", "terra"),
    cache        = FALSE,
    overwrite    = FALSE,
    verbose      = TRUE,
    method       = c("curl", "wget"),
    background   = FALSE
) {

  # ── Background mode ────────────────────────────────────────────────────────
  if (isTRUE(background)) {
    if (!requireNamespace("callr", quietly = TRUE)) {
      cli::cli_abort(c(
        "{.arg background = TRUE} requires the {.pkg callr} package.",
        "i" = "Install it with {.code install.packages(\"callr\")}."
      ))
    }
    return(callr::r_bg(
      func = get_mtbs,
      args = list(
        url        = url,
        years      = years,
        type       = type,
        geometry   = geometry,
        output     = output[[1L]],
        cache      = cache,
        overwrite  = overwrite,
        verbose    = FALSE,
        method     = method[[1L]],
        background = FALSE
      ),
      package = TRUE
    ))
  }

  # ── Argument validation ────────────────────────────────────────────────────
  output <- rlang::arg_match(output)
  method <- rlang::arg_match(method)

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

  # ── Resolve download destination ───────────────────────────────────────────
  zip_path <- .resolve_cache(url, cache, overwrite, verbose)

  # ── Download ───────────────────────────────────────────────────────────────
  if (!fs::file_exists(zip_path)) {
    .download_fast(url, zip_path, verbose, method)
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

  # ── Build OGR SQL query for efficient attribute-level filtering ────────────
  layer <- tools::file_path_sans_ext(basename(shp_path))
  where_clauses <- character(0)

  if (!is.null(years)) {
    start_date <- sprintf("%04d-01-01", years[[1L]])
    end_date   <- sprintf("%04d-12-31", years[[2L]])
    where_clauses <- c(
      where_clauses,
      sprintf("Ig_Date >= '%s' AND Ig_Date <= '%s'", start_date, end_date)
    )
  }

  if (!is.null(type)) {
    # Use OR-joined equality tests instead of IN (...) to avoid OGR SQL
    # parser issues with the IN operator in some GDAL versions.
    type_eq <- paste(sprintf("Incid_Type = '%s'", type), collapse = " OR ")
    where_clauses <- c(where_clauses, sprintf("(%s)", type_eq))
  }

  sql_query <- if (length(where_clauses) > 0L) {
    sprintf(
      "SELECT * FROM \"%s\" WHERE %s",
      layer,
      paste(where_clauses, collapse = " AND ")
    )
  } else {
    NULL
  }

  # ── Read shapefile via terra (much faster than sf::st_read for large files) ─
  if (verbose) cli::cli_progress_step("Reading {.path {basename(shp_path)}} \u2026")
  data_sv <- if (!is.null(sql_query)) {
    terra::vect(shp_path, query = sql_query)
  } else {
    terra::vect(shp_path)
  }
  if (verbose) cli::cli_progress_done()

  if (verbose && (!is.null(years) || !is.null(type))) {
    cli::cli_inform("Returned {nrow(data_sv)} fire perimeter{?s}.")
  }

  # ── Return ─────────────────────────────────────────────────────────────────
  if (!geometry) {
    return(as.data.frame(terra::values(data_sv)))
  }

  if (output == "sf") {
    return(sf::st_as_sf(data_sv))
  }

  # terra::SpatVector
  data_sv
}


# ── Internal helpers ──────────────────────────────────────────────────────────

#' @keywords internal
.resolve_cache <- function(url, cache, overwrite, verbose) {
  file_name <- basename(url)

  if (isFALSE(cache)) {
    # Use tempfile() for a unique, cross-platform safe path (no locale issues)
    tmp_dir <- file.path(tempfile(pattern = "fireR_"), "dl")
    fs::dir_create(tmp_dir, recurse = TRUE)
    return(fs::path(tmp_dir, file_name))
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
.download_fast <- function(url, dest, verbose, method = "curl") {
  if (verbose) {
    cli::cli_progress_step(
      "Downloading MTBS perimeter data ({.url {url}}) \u2026"
    )
  }

  if (method == "wget") {
    # Check wget is available; fall back to curl with a warning
    if (nchar(Sys.which("wget")) == 0L) {
      cli::cli_warn(c(
        "{.code wget} not found on PATH; falling back to {.pkg curl}.",
        "i" = "Install wget or use {.code method = \"curl\"}."
      ))
      method <- "curl"
    }
  }

  if (method == "wget") {
    tryCatch(
      utils::download.file(url, destfile = dest, method = "wget",
                           quiet = !verbose, mode = "wb"),
      error = function(e) {
        cli::cli_abort(c(
          "Download failed.",
          "i" = "URL: {.url {url}}",
          "x" = conditionMessage(e)
        ))
      }
    )
  } else {
    tryCatch(
      curl::curl_download(
        url      = url,
        destfile = dest,
        quiet    = !verbose,
        handle   = curl::new_handle(
          http_version   = 2L,    # CURL_HTTP_VERSION_2 (falls back to 1.1)
          tcp_keepalive  = 1L,
          followlocation = 1L,
          ssl_verifypeer = 1L,
          timeout        = 0L,    # no timeout — large files need unlimited time
          connecttimeout = 30L    # but fail fast if the server is unreachable
        )
      ),
      error = function(e) {
        cli::cli_abort(c(
          "Download failed.",
          "i" = "URL: {.url {url}}",
          "x" = conditionMessage(e)
        ))
      }
    )
  }

  if (verbose) cli::cli_progress_done()
  invisible(dest)
}
