#' Download and unzip USFS Wildland-Urban Interface (WUI) data
#'
#' Downloads the USFS Wildland-Urban Interface (WUI) dataset ZIP from the
#' USFS public Box archive and unzips it to a local directory.  If the ZIP
#' already exists and \code{overwrite = FALSE}, no network call is made.
#'
#' @section Warning \[large file\]:
#' The WUI ZIP archive is approximately \strong{4.65 GB}.  Downloads are slow
#' and may take tens of minutes depending on connection speed.  It is strongly
#' recommended to source this function in a background R session (e.g. with
#' \code{callr::r_bg()}) so your interactive session remains responsive.
#'
#' @section About USFS WUI:
#' The Wildland-Urban Interface (WUI) dataset produced by the US Forest Service
#' delineates areas where structures and human development meet or intermingle
#' with undeveloped wildland vegetation.  The WUI is a critical planning layer
#' for fire risk assessment, fuels management, and community preparedness.
#' Data are sourced from the USFS public archive hosted on Box.
#'
#' @param directory \code{character(1)} directory where the ZIP file and
#'   unzipped contents are stored.  Defaults to the current working directory.
#' @param overwrite \code{logical(1)} re-download when \code{TRUE};
#'   defaults to \code{FALSE}.
#' @param timeout \code{numeric(1)} download timeout in seconds.
#'   Defaults to \code{3600} (one hour).
#' @param verbose \code{logical(1)} print progress messages.
#'
#' @return \code{character(1)} path to the downloaded ZIP file (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' # Recommended: run in a background session (4.65 GB download)
#' bg <- callr::r_bg(function() fireR::get_wui(directory = "data/wui"))
#' bg$wait()
#'
#' # Download to the current directory
#' zip_path <- get_wui()
#'
#' # Download to a specific directory
#' zip_path <- get_wui(directory = "data/wui")
#' }
get_wui <- function(
    directory = getwd(),
    overwrite = FALSE,
    timeout   = 3600,
    verbose   = TRUE
) {
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

  url      <- "https://usfs-public.box.com/shared/static/bjupat9dkwln7yanslfls0zb4n949qv2.zip"
  zip_name <- "usfs_wui.zip"
  zip_file <- fs::path(directory, zip_name)

  fs::dir_create(directory, recurse = TRUE)

  if (overwrite && fs::file_exists(zip_file)) fs::file_delete(zip_file)

  did_download <- FALSE
  if (!fs::file_exists(zip_file)) {
    cli::cli_warn(c(
      "!" = "The USFS WUI ZIP is approximately {.strong 4.65 GB} and will be slow to download.",
      "i" = "Consider running {.fn get_wui} in a background session to keep R responsive:",
      " " = "{.code bg <- callr::r_bg(function() fireR::get_wui(directory = \"{directory}\"))}"
    ))
    if (verbose) cli::cli_inform("Downloading USFS Wildland-Urban Interface (WUI) data \u2026")
    curl::curl_download(url, destfile = zip_file,
                        handle = curl::new_handle(followlocation = TRUE, useragent = .ua_string, timeout = as.integer(timeout)),
                        quiet  = FALSE)
    if (verbose) cli::cli_inform("Download complete: {.path {zip_file}}")
    did_download <- TRUE
  } else if (verbose) {
    cli::cli_inform("WUI ZIP already exists: {.path {zip_file}}")
  }

  if (did_download) {
    if (verbose) cli::cli_inform("Unzipping {.path {zip_file}} \u2026")
    utils::unzip(zip_file, exdir = directory)
    if (verbose) cli::cli_inform("Unzip complete: {.path {directory}}")
  }

  invisible(zip_file)
}
