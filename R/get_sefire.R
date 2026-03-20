#' Download Southeast FireMap Annual Burn Severity Mosaics
#'
#' Downloads one or more Southeast FireMap (SE FireMap) Annual Burn Severity
#' Mosaic ZIP archives from the USGS to a local directory.  If a ZIP already
#' exists and \code{overwrite = FALSE}, no network call is made for that year.
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
#' across the southeastern United States for years 2000–2022.  These mosaics
#' improve characterisation of burn severity—including small and prescribed
#' fires that are under-represented in national datasets—and support estimation
#' of fire-related emissions, fuel loads, aboveground carbon storage, and land
#' management activities.
#'
#' @param years \code{integer} vector of years to download.  Accepts a single
#'   year (\code{2020}), a contiguous range created with \code{:} notation
#'   (\code{2010:2015}), or a vector of specific years
#'   (\code{c(2000, 2010, 2020)}).  All values must be between \code{2000}
#'   and \code{2022} (inclusive).  Duplicate years are silently ignored.
#' @param directory \code{character(1)} directory where the ZIP file(s) are
#'   saved.  Defaults to the current working directory.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param timeout \code{numeric(1)} download timeout in seconds.
#'   Defaults to \code{3600} (one hour).
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character} vector of paths to the downloaded ZIP files
#'   (returned invisibly).  The length equals the number of unique years
#'   requested.
#' @export
#'
#' @examples
#' \dontrun{
#' # Single year
#' zip_path <- get_sefire(2010)
#'
#' # Contiguous range (2015 through 2020)
#' zip_paths <- get_sefire(2015:2020, directory = "data/sefire")
#'
#' # Specific years only
#' zip_paths <- get_sefire(c(2000, 2010, 2020))
#' }
get_sefire <- function(
    years,
    directory = getwd(),
    overwrite = FALSE,
    timeout   = 3600,
    verbose   = TRUE
) {
  years <- as.integer(years)
  if (length(years) == 0L || any(is.na(years))) {
    stop("`years` must be a non-empty integer vector with no NA values")
  }
  if (any(years < 2000L) || any(years > 2022L)) {
    stop("`years` must be between 2000 and 2022 (inclusive)")
  }
  years <- sort(unique(years))

  fs::dir_create(directory, recurse = TRUE)
  old_timeout <- options(timeout = timeout)
  on.exit(options(old_timeout), add = TRUE)

  zip_files <- character(length(years))
  for (i in seq_along(years)) {
    yr       <- years[i]
    url      <- paste0(
      "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/SeFiremap/cbi_mosaic_",
      yr, ".zip"
    )
    zip_name <- paste0("cbi_mosaic_", yr, ".zip")
    zip_file <- fs::path(directory, zip_name)

    if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

    if (!fs::file_exists(zip_file)) {
      if (verbose) cli::cli_inform("Downloading SE FireMap CBI mosaic for {yr} \u2026")
      utils::download.file(url, zip_file, mode = "wb", quiet = !verbose)
      if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
    } else if (verbose) {
      cli::cli_inform("SE FireMap ZIP already exists: {.path {zip_file}}")
    }

    zip_files[i] <- zip_file
  }

  invisible(zip_files)
}
