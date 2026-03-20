#' Download and Load MTBS Fire Perimeter Data
#'
#' Downloads the MTBS composite burned-area extent shapefile from the USGS
#' and returns fire perimeters as a spatial object. The shapefile is read
#' directly from the ZIP archive via GDAL's \code{/vsizip/} virtual
#' filesystem — no extraction to disk. Reading is performed via \code{terra}
#' (significantly faster than \code{sf} for large files) and converted to
#' \code{sf} only when requested. Year and type filtering is performed via an
#' OGR SQL query so only matching features are read into memory.
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
#'   Defaulting to \code{"vect"} avoids the overhead of converting to
#'   \code{sf} when it is not needed. Ignored when \code{geometry = FALSE}.
#' @param cache \code{logical(1)} or \code{character(1)}. When \code{FALSE}
#'   (the default) the ZIP is downloaded to a per-session temporary directory
#'   and deleted when the R session ends. When \code{TRUE} the file is cached
#'   in \code{tools::R_user_dir("fireR", "cache")} so subsequent calls skip
#'   the download entirely. Alternatively, supply a directory path as a
#'   string to control the cache location yourself.
#' @param overwrite \code{logical(1)} When \code{cache} is enabled, set
#'   \code{TRUE} to force a fresh download even if a cached copy exists.
#'   Defaults to \code{FALSE}.
#' @param verbose \code{logical(1)} Print progress messages. Defaults to
#'   \code{TRUE}.
#' @param background \code{logical(1)} When \code{TRUE} the download and all
#'   subsequent processing runs in a background R process via
#'   \code{callr::r_bg()}, so your interactive session stays responsive. The
#'   function returns a \code{callr} process object immediately; call
#'   \code{$wait()} to block until it finishes and \code{$get_result()} to
#'   retrieve the spatial object. Requires the \pkg{callr} package. Defaults
#'   to \code{FALSE}.
#'
#' @return
#' \itemize{
#'   \item When \code{background = FALSE} (default):
#'   \itemize{
#'     \item A \code{terra::SpatVector} when \code{output = "vect"} /
#'       \code{"terra"} and \code{geometry = TRUE}.
#'     \item An \code{sf} object when \code{output = "sf"} and
#'       \code{geometry = TRUE}.
#'     \item A \code{data.frame} when \code{geometry = FALSE}.
#'   }
#'   \item When \code{background = TRUE}: a \code{callr} \code{r_process}
#'     object. Use \code{$wait()} then \code{$get_result()} to obtain the
#'     spatial object.
#' }
#'
#' @details
#' ## Speed
#' Three design decisions keep this function fast:
#'
#' 1. **No extraction to disk.** The shapefile is read directly from the ZIP
#'    via GDAL's \code{/vsizip/} virtual filesystem. \code{utils::unzip()} is
#'    called only to inspect the ZIP's table of contents (near-instant), never
#'    to extract files.
#'
#' 2. **\code{terra::SpatVector} is the default output** (\code{output =
#'    "vect"}). The \code{terra} C++ layer reads shapefiles substantially
#'    faster than \code{sf::st_read()}, and skipping the
#'    \code{sf::st_as_sf()} conversion saves additional time. Pass
#'    \code{output = "sf"} explicitly when you need an \code{sf} object.
#'
#' 3. **OGR SQL filtering** is applied at read time via \code{terra::vect()},
#'    so only matching features are loaded into memory.
#'
#' ## Non-blocking mode
#' Pass \code{background = TRUE} to keep your R session responsive while the
#' ~100 MB archive downloads and is processed:
#'
#' ```r
#' proc <- get_mtbs(years = 2020, background = TRUE)
#' # … do other work …
#' proc$wait()
#' fires <- proc$get_result()
#' ```
#'
#' \code{background = TRUE} requires the \pkg{callr} package
#' (\code{install.packages("callr")}).
#'
#' ## Year and type filtering
#' Filtering is performed as an OGR SQL \code{WHERE} clause passed directly
#' to \code{terra::vect()}, so only matching features are read into memory.
#' Years are matched against the \code{Ig_Date} column (e.g.
#' \code{1997-04-23}); incident types are matched against the
#' \code{Incid_Type} column.
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
#' }
#'
#' @export
get_mtbs <- function(
    url        = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
    years      = NULL,
    type       = NULL,
    geometry   = TRUE,
    output     = c("vect", "sf", "terra"),
    cache      = FALSE,
    overwrite  = FALSE,
    verbose    = TRUE,
    background = FALSE
) {

  # ── Background mode ────────────────────────────────────────────────────────
  if (isTRUE(background)) {
    if (!requireNamespace("callr", quietly = TRUE)) {
      cli::cli_abort(c(
        "{.arg background = TRUE} requires the {.pkg callr} package.",
        "i" = "Install it with {.code install.packages(\"callr\")}."
      ))
    }
    proc <- callr::r_bg(
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
        background = FALSE
      ),
      package = TRUE
    )
    if (verbose) {
      cli::cli_inform(c(
        "i" = "Processing in background. Call {.code proc$wait()} then {.code proc$get_result()} when ready."
      ))
    }
    return(proc)
  }

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

  # ── Resolve download destination ───────────────────────────────────────────
  zip_path <- .resolve_cache(url, cache, overwrite, verbose)

  # ── Download ───────────────────────────────────────────────────────────────
  if (!fs::file_exists(zip_path)) {
    .download_zip(url, zip_path, verbose)
  } else {
    if (verbose) cli::cli_inform("c" = "Using cached file: {.path {zip_path}}")
  }

  # ── Locate shapefile inside ZIP (table-of-contents only, no extraction) ────
  zip_contents <- utils::unzip(zip_path, list = TRUE)$Name
  shp_name     <- zip_contents[grepl("\\.shp$", zip_contents, ignore.case = TRUE)]

  if (length(shp_name) == 0L) {
    cli::cli_abort(
      "No {.file .shp} file found inside {.path {zip_path}}. \\
      Check that {.url {url}} returns a valid shapefile ZIP."
    )
  }

  shp_name <- shp_name[[1L]]

  # Build GDAL virtual path — reads directly from ZIP, no disk extraction
  vsi_path <- paste0(
    "/vsizip/",
    normalizePath(zip_path, winslash = "/"),
    "/",
    shp_name
  )

  # ── Build OGR SQL query for efficient attribute-level filtering ────────────
  layer         <- tools::file_path_sans_ext(basename(shp_name))
  where_clauses <- character(0)

  if (!is.null(years)) {
    start_date    <- sprintf("%04d-01-01", years[[1L]])
    end_date      <- sprintf("%04d-12-31", years[[2L]])
    where_clauses <- c(
      where_clauses,
      sprintf("Ig_Date >= '%s' AND Ig_Date <= '%s'", start_date, end_date)
    )
  }

  if (!is.null(type)) {
    type_eq       <- paste(sprintf("Incid_Type = '%s'", type), collapse = " OR ")
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

  # ── Read via terra directly from ZIP ──────────────────────────────────────
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
  if (!geometry) {
    return(as.data.frame(terra::values(data_sv)))
  }

  if (output == "sf") {
    return(sf::st_as_sf(data_sv))
  }

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
.download_zip <- function(url, dest, verbose) {
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
      handle   = curl::new_handle(
        http_version   = 2L,
        tcp_keepalive  = 1L,
        followlocation = 1L,
        ssl_verifypeer = 1L,
        timeout        = 0L,
        connecttimeout = 30L
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

  if (verbose) cli::cli_progress_done()
  invisible(dest)
}
