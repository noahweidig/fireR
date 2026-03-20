#' fireR: Fast Access to MTBS Fire Perimeter Data
#'
#' @description `fireR` provides two ergonomic entry points for MTBS
#' (Monitoring Trends in Burn Severity) composite burned-area extent data:
#' [get_mtbs()] for downloading/unzipping, and [read_mtbs()] for reading and
#' filtering data as an [`sf`][sf::sf] object, a
#' [`terra::SpatVector`][terra::vect], or a plain `data.frame`.
#'
#' @section Main functions:
#' * [get_mtbs()] — download and unzip MTBS fire perimeter data.
#' * [read_mtbs()] — read, filter, and return MTBS fire perimeters.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom curl curl_download new_handle
#' @importFrom fs dir_create dir_ls file_exists file_delete path path_dir
#' @importFrom cli cli_abort cli_inform cli_warn cli_progress_step cli_progress_done
#' @importFrom rlang arg_match is_bool
#' @importFrom sf st_read st_drop_geometry
#' @importFrom terra vect
## usethis namespace: end
NULL
