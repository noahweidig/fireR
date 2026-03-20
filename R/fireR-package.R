#' fireR: Fast Access to MTBS Fire Perimeter Data
#'
#' @description `fireR` provides two ergonomic entry points for MTBS
#' (Monitoring Trends in Burn Severity) composite burned-area extent data:
#' [get_mtbs()] for downloading, and [read_mtbs()] for reading and
#' filtering data as an [`sf`][sf::sf] object, a
#' [`terra::SpatVector`][terra::vect], or a plain `data.frame`.
#'
#' @section Main functions:
#' * [get_mtbs()] — download MTBS fire perimeter ZIP data.
#' * [read_mtbs()] — read, filter, and return MTBS fire perimeters.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom fs dir_create file_exists file_delete path
#' @importFrom cli cli_inform
#' @importFrom rlang arg_match
#' @importFrom sf st_as_sf
#' @importFrom terra vect values
## usethis namespace: end
NULL
