#' Download and Load MTBS Fire Perimeter Data
#'
#' Downloads the MTBS composite burned-area extent shapefile from the USGS
#' and returns fire perimeters as a spatial object. The shapefile is read
#' directly from the ZIP archive via GDAL's \code{/vsizip/} virtual
#' filesystem — no extraction to disk. Reading is performed via \code{terra}
#' and converted to \code{sf} only when requested. Year and type filtering
#' is performed via an OGR SQL query so only matching features are read into
#' memory.
#'
#' @param url \code{character(1)} URL of the MTBS perimeter ZIP archive.
#'   Defaults to the official USGS composite data endpoint.
#' @param years \code{integer} vector of length 1 or 2 specifying the year
#'   range to keep. If a single year is supplied, only fires from that year
#'   are returned. If two years are supplied they are treated as
#'   \code{c(start_year, end_year)} (inclusive). \code{NULL} (the default)
#'   returns all years without filtering. Filtering is based on the
#'   \code{Ig_Date} column (format \code{YYYY-MM-DD}) via OGR SQL.
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
#'   (the default) the ZIP is downloaded to a per-session temporary directory
#'   and deleted when the R session ends. When \code{TRUE} the file is cached
#'   in \code{tools::R_user_dir("fireR", "cache")} so subsequent calls skip
#'   the download entirely. Alternatively, supply a directory path as a
#'   string to control the cache location yourself.
#' @param overwrite \code{logical(1)} When \code{cache} is enabled, set
#'   \code{TRUE} to force a fresh download even if a cached copy exists.
#'   Defaults to \code{FALSE}.
#' @param retries \code{integer(1)} Number of download retry attempts on
#'   failure or stall. Defaults to \code{3L}.
#' @param timeout \code{integer(1)} Maximum number of seconds to allow for
#'   the entire download before aborting and retrying. Defaults to
#'   \code{300L} (5 minutes). Increase for very slow connections.
#' @param verbose \code{logical(1)} Print progress messages. Defaults to
#'   \code{TRUE}.
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
#' ## Speed
#' Three design decisions keep this function fast:
#'
#' 1. **No extraction to disk.** The shapefile is read directly from the ZIP
#'    via GDAL's \code{/vsizip/} virtual filesystem.
#'
#' 2. **\code{terra::SpatVector} is the default output.** The \code{terra}
#'    C++ layer reads shapefiles substantially faster than \code{sf::st_read()}.
#'    Pass \code{output = "sf"} explicitly when you need an \code{sf} object.
#'
#' 3. **OGR SQL filtering** is applied at read time, so only matching features
#'    are loaded into memory.
#'
#' ## Caching
#' The first call with \code{cache = TRUE} downloads the ~100 MB archive once.
#' All subsequent calls read from disk and skip the download entirely.
#' This is the most effective way to avoid slow or stalled downloads.
#'
#' ```r
#' # First call: downloads and caches
#' fires <- get_mtbs(cache = TRUE)
#'
#' # All future calls: instant, no network
#' fires <- get_mtbs(cache = TRUE)
#' ```
#'
#' ## Retries
#' On slow or unreliable connections, \code{retries} controls how many times
#' the download is attempted before giving up. Each attempt honours
#' \code{timeout} seconds. A partial file is deleted before each retry.
#'
#' ## Year and type filtering
#' Years are matched against the \code{Ig_Date} column (e.g.
#' \code{1997-04-23}); incident types are matched against \code{Incid_Type}.
#'
#' @examples
#' \dontrun{
#' # Default: all years, return as terra SpatVector
#' fires <- get_mtbs()
#'
#' # Cache for instant loads in future sessions (recommended)
#' fires <- get_mtbs(cache = TRUE)
#'
#' # Only fires from 2020 to 2023
#' fires_recent <- get_mtbs(years = c(2020, 2023), cache = TRUE)
#'
#' # Single year, wildfires only, as sf
#' fires_2020 <- get_mtbs(years = 2020, type = "Wildfire", output = "sf")
#'
#' # Attribute table only (no geometry)
#' tbl <- get_mtbs(geometry = FALSE)
#'
#' # Slow connection: extend timeout, add retries
#' fires <- get_mtbs(cache = TRUE, timeout = 600L, retries = 5L)
#' }
#'
#' @export
get_mtbs <- function(
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

  retries <- max(1L, as.integer(retries))
  timeout <- max(30L, as.integer(timeout))

  # ── Resolve download destination ───────────────────────────────────────────
  zip_path <- .resolve_cache(url, cache, overwrite, verbose)

  # ── Download (with retries) ────────────────────────────────────────────────
  if (!fs::file_exists(zip_path)) {
    .download_zip(url, zip_path, retries = retries, timeout = timeout,
                  verbose = verbose)
  } else {
    if (verbose) cli::cli_inform("Using cached file: {.path {zip_path}}")
  }

  # ── Locate shapefile inside ZIP ────────────────────────────────────────────
  zip_contents <- utils::unzip(zip_path, list = TRUE)$Name
  shp_name     <- zip_contents[grepl("\\.shp$", zip_contents,
                                     ignore.case = TRUE)]

  if (length(shp_name) == 0L) {
    cli::cli_abort(c(
      "No {.file .shp} found inside {.path {zip_path}}.",
      "i" = "The ZIP may be corrupt. Re-run with {.code overwrite = TRUE} to force a fresh download."
    ))
  }

  shp_name <- shp_name[[1L]]
  vsi_path <- paste0("/vsizip/", normalizePath(zip_path, winslash = "/"),
                     "/", shp_name)

  # ── Build OGR SQL WHERE clause ─────────────────────────────────────────────
  layer         <- tools::file_path_sans_ext(basename(shp_name))
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

  # ── Read via terra ─────────────────────────────────────────────────────────
  if (verbose) cli::cli_progress_step("Reading {.path {basename(shp_name)}} \u2026")

  data_sv <- if (!is.null(sql_query)) {
    terra::vect(vsi_path, query = sql_query)
  } else {
    terra::vect(vsi_path)
  }

  if (verbose) cli::cli_progress_done()

  if (verbose && (!is.null(years) || !is.null(type))) {
    cli::cli_inform("Returned {nrow(data_sv)} fire perimeter{?s}.")
  }

  # ── Return ─────────────────────────────────────────────────────────────────
  if (!geometry) return(as.data.frame(terra::values(data_sv)))
  if (output == "sf") return(sf::st_as_sf(data_sv))
  data_sv
}


# ── Internal helpers ──────────────────────────────────────────────────────────

#' @keywords internal
.resolve_cache <- function(url, cache, overwrite, verbose) {
  file_name <- basename(url)

  if (isFALSE(cache)) {
    tmp_dir <- file.path(tempfile(pattern = "fireR_"), "dl")
    fs::dir_create(tmp_dir, recurse = TRUE)
    return(fs::path(tmp_dir, file_name))
  }

  cache_dir <- if (isTRUE(cache)) {
    fs::path(tools::R_user_dir("fireR", "cache"))
  } else {
    fs::path(cache)
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
.download_zip <- function(url, dest, retries, timeout, verbose) {

  attempt <- 0L

  repeat {
    attempt <- attempt + 1L

    if (verbose) {
      cli::cli_progress_step(
        "Downloading MTBS perimeter data (attempt {attempt}/{retries}) \u2026"
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
          timeout        = timeout,   # hard ceiling per attempt
          connecttimeout = 30L,
          low_speed_limit = 1000L,    # abort if < 1 KB/s …
          low_speed_time  = 30L       # … for 30 consecutive seconds
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

    if (verbose) cli::cli_inform("Retrying in 5 seconds \u2026")
    Sys.sleep(5)
  }
}
