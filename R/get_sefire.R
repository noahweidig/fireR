#' Download Southeast FireMap Datasets
#'
#' Downloads Southeast FireMap (SE FireMap) data products from the USGS and the
#' SE FireMap S3 archive to a local directory.  Four \code{dataset} options are
#' available: annual Burn Severity mosaics (one ZIP per year), a single-file
#' Fire History map, Burned Area Polygons, or Burned Area Rasters.  If a ZIP
#' already exists and \code{overwrite = FALSE}, no network call is made.
#'
#' @section About SE FireMap:
#' The southeastern United States experiences frequent wild and prescribed fire
#' activity.  The USGS developed a gradient-boosted decision tree model trained
#' on over 5,000 Composite Burn Inventory (CBI) field plots to predict
#' post-fire burn severity as a CBI value (0–3) across the region.  The model
#' ingests ARD Landsat predictors capturing first- and second-order fire
#' effects, climate norms, and fire seasonality, then applies the trained model
#' to the extent of burned area identified by the Landsat Burned Area Product.
#' The result is an annual burn severity mosaic covering 78 ARD Landsat tiles
#' across the southeastern United States for years 2000–2022.
#'
#' The SE FireMap Fall 2024 release additionally provides a Fire History Map
#' (1994–2024), Burned Area Polygons (1994–2024), and Burned Area Raster grids
#' (1994–2024) as single-file geodatabase ZIPs.  Year selection is not
#' applicable to these three products; the \code{years} argument is silently
#' ignored when they are requested.
#'
#' @param dataset \code{character(1)} the SE FireMap product to download.
#'   One of \code{"Burn Severity"} (default), \code{"Fire History"},
#'   \code{"Burned Area Polygons"}, or \code{"Burned Area Rasters"}.
#'   \code{"Burn Severity"} downloads one ZIP per year from USGS and requires
#'   the \code{years} argument.  The remaining three products cover 1994–2024
#'   as a single ZIP each and do not use \code{years}.
#' @param years \code{integer} vector of years to download.  Used only when
#'   \code{dataset = "Burn Severity"}.  Accepts a single year (\code{2020}),
#'   a contiguous range created with \code{:} notation (\code{2010:2015}), or
#'   a vector of specific years (\code{c(2000, 2010, 2020)}).  All values must
#'   be between \code{2000} and \code{2022} (inclusive).  Duplicate years are
#'   silently ignored.  Ignored for all other datasets.
#' @param directory \code{character(1)} directory where the ZIP file(s) are
#'   saved.  Defaults to the current working directory.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param timeout \code{numeric(1)} download timeout in seconds.
#'   Defaults to \code{3600} (one hour).
#' @param verbose \code{logical(1)} print progress messages.
#' @param dry_run \code{logical(1)} if \code{TRUE}, do not download the file but instead return the path where it would be saved. Defaults to \code{FALSE}.
#'
#' @return For \code{dataset = "Burn Severity"}: a \code{character} vector of
#'   paths to the downloaded ZIP files (returned invisibly), one element per
#'   unique year requested.  For all other datasets: a \code{character(1)} path
#'   to the downloaded ZIP file (returned invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' # Burn Severity -- single year
#' zip_path <- get_sefire(years = 2010)
#'
#' # Burn Severity -- contiguous range (2015 through 2020)
#' zip_paths <- get_sefire(years = 2015:2020, directory = "data/sefire")
#'
#' # Burn Severity -- specific years only
#' zip_paths <- get_sefire(years = c(2000, 2010, 2020))
#'
#' # Fire History (1994-2024)
#' zip_path <- get_sefire(dataset = "Fire History", directory = "data/sefire")
#'
#' # Burned Area Polygons (1994-2024)
#' zip_path <- get_sefire(dataset = "Burned Area Polygons", directory = "data/sefire")
#'
#' # Burned Area Rasters (1994-2024)
#' zip_path <- get_sefire(dataset = "Burned Area Rasters", directory = "data/sefire")
#' }
get_sefire <- function(
    dataset   = c("Burn Severity", "Fire History", "Burned Area Polygons", "Burned Area Rasters"),
    years     = NULL,
    directory = getwd(),
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

  if (!dry_run) {
    fs::dir_create(directory, recurse = TRUE)
  }

  ## ── Burn Severity (year-based, USGS, parallel downloads) ─────────────────
  if (dataset == "Burn Severity") {
    if (is.null(years)) {
      stop('`years` must be provided when dataset = "Burn Severity"')
    }
    if (!is.numeric(years) || length(years) == 0L || any(is.na(years)) || any(years %% 1 != 0)) {
      stop("`years` must be a non-empty integer vector with no NA values")
    }
    years <- as.integer(years)
    if (any(years < 2000L) || any(years > 2022L)) {
      stop("`years` must be between 2000 and 2022 (inclusive)")
    }
    years <- sort(unique(years))

    urls      <- paste0(
      "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/SeFiremap/cbi_mosaic_",
      years, ".zip"
    )
    zip_names <- paste0("cbi_mosaic_", years, ".zip")
    zip_files <- fs::path(directory, zip_names)

    if (dry_run) {
      if (verbose) cli::cli_inform("Dry run: Would download {length(zip_files)} SE FireMap Burn Severity mosaic{?s} to {.path {directory}}")
      return(invisible(zip_files))
    }

    # Handle overwrite: delete any existing files that should be re-downloaded
    if (overwrite) {
      existing <- fs::file_exists(zip_files)
      if (any(existing)) fs::file_delete(zip_files[existing])
    }

    # Identify which files still need to be downloaded
    to_download <- !fs::file_exists(zip_files)

    if (any(to_download)) {
      n <- sum(to_download)
      cli::cli_warn(c("!" = "This is a large download (hundreds of megabytes)."))
      if (verbose) {
        cli::cli_inform(
          "Downloading {n} SE FireMap Burn Severity mosaic{?s} \u2026"
        )
      }
      results <- curl::multi_download(
        urls[to_download],
        zip_files[to_download],
        progress  = verbose,
        useragent = .ua_string,
        timeout   = as.integer(timeout)
      )
      failed <- results[is.na(results$success) | !results$success, , drop = FALSE]
      if (nrow(failed) > 0L) {
        failed_msgs <- paste0(failed$url, " (HTTP ", failed$status_code, ")")
        names(failed_msgs) <- rep("x", length(failed_msgs))
        cli::cli_warn(c(
          "!" = "{nrow(failed)} SE FireMap download{?s} failed:",
          failed_msgs
        ))
      } else if (verbose) {
        cli::cli_inform("Download{?s} complete.")
      }
    } else if (verbose) {
      cli::cli_inform("All requested SE FireMap Burn Severity ZIPs already exist.")
    }

    return(invisible(zip_files))
  }

  ## ── Single-file datasets (SE FireMap S3, curl) ────────────────────────────
  if (!is.null(years) && verbose) {
    cli::cli_warn('`years` is ignored when dataset = "{dataset}"')
  }

  ds_info <- switch(
    dataset,
    "Fire History" = list(
      url      = "https://se-firemap-data-requests.s3.us-east-1.amazonaws.com/SEFM_1994_2024_FallRelease/SEFM_L_FHM_1994_2024.gdb.zip",
      zip_name = "SEFM_L_FHM_1994_2024.gdb.zip",
      label    = "SE FireMap Fire History (1994\u20132024)"
    ),
    "Burned Area Polygons" = list(
      url      = "https://se-firemap-data-requests.s3.us-east-1.amazonaws.com/SEFM_1994_2024_FallRelease/SEFM_L_ABA_1994_2024_polys.gdb.zip",
      zip_name = "SEFM_L_ABA_1994_2024_polys.gdb.zip",
      label    = "SE FireMap Burned Area Polygons (1994\u20132024)"
    ),
    "Burned Area Rasters" = list(
      url      = "https://se-firemap-data-requests.s3.us-east-1.amazonaws.com/SEFM_1994_2024_FallRelease/SEFM_L_ABA_1994_2024_rasters.gdb.zip",
      zip_name = "SEFM_L_ABA_1994_2024_rasters.gdb.zip",
      label    = "SE FireMap Burned Area Rasters (1994\u20132024)"
    )
  )

  zip_file <- fs::path(directory, ds_info$zip_name)

  if (dry_run) {
    if (verbose) cli::cli_inform("Dry run: Would download {ds_info$label} to {.path {zip_file}}")
    return(invisible(zip_file))
  }

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  if (!fs::file_exists(zip_file)) {
    cli::cli_warn(c("!" = "This is a large download (hundreds of megabytes)."))
    if (verbose) cli::cli_inform("Downloading {ds_info$label} \u2026")
    handle <- curl::new_handle(
      followlocation = TRUE,
      useragent      = .ua_string,
      timeout        = as.integer(timeout)
    )
    curl::curl_download(ds_info$url, destfile = zip_file,
                        handle = handle,
                        quiet  = !verbose)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("SE FireMap ZIP already exists: {.path {zip_file}}")
  }

  invisible(zip_file)
}
