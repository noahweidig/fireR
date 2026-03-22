.dl_handle <- curl::new_handle(
  followlocation = TRUE,
  timeout        = 3600L,
  useragent      = paste0(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
    "AppleWebKit/537.36 (KHTML, like Gecko) ",
    "Chrome/124.0.0.0 Safari/537.36")
)

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

  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading NIFC wildfire perimeters \u2026")
    curl::curl_download(url, destfile = zip_file,
                        handle = curl::handle_reset(.dl_handle),
                        quiet  = FALSE)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("NIFC ZIP already exists: {.path {zip_file}}")
  }

  if (verbose) cli::cli_inform("Unzipping {.path {zip_file}} \u2026")
  utils::unzip(zip_file, exdir = directory)
  if (verbose) cli::cli_inform("Unzip complete: {.path {directory}}")

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

  if (!fs::file_exists(zip_file)) {
    if (verbose) cli::cli_inform("Downloading USFS Fire Occurrence Database (FOD) \u2026")
    httr2::request(url) |>
      httr2::req_headers(
        "User-Agent" = paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
                              "AppleWebKit/537.36 (KHTML, like Gecko) ",
                              "Chrome/124.0.0.0 Safari/537.36"),
        "Accept"     = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Referer"    = "https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0009.6"
      ) |>
      httr2::req_timeout(3600) |>
      httr2::req_perform(path = zip_file)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
  } else if (verbose) {
    cli::cli_inform("FOD ZIP already exists: {.path {zip_file}}")
  }

  if (verbose) cli::cli_inform("Unzipping {.path {zip_file}} \u2026")
  utils::unzip(zip_file, exdir = directory)
  if (verbose) cli::cli_inform("Unzip complete: {.path {directory}}")

  invisible(zip_file)
}
