#' fireR: Fast Access to MTBS and SE FireMap Fire Data
#'
#' @description `fireR` provides ergonomic entry points for USGS fire data:
#' [get_mtbs()] and [read_mtbs()] for MTBS (Monitoring Trends in Burn
#' Severity) composite burned-area extent data, and [get_sefire()] for
#' Southeast FireMap Annual Burn Severity Mosaics.  Spatial results can be
#' returned as an [`sf`][sf::sf] object, a
#' [`terra::SpatVector`][terra::vect], or a plain `data.frame`.
#'
#' @section Main functions:
#' * [get_mtbs()] — download MTBS fire perimeter ZIP data.
#' * [read_mtbs()] — read, filter, and return MTBS fire perimeters.
#' * [get_sefire()] — download a SE FireMap Annual Burn Severity Mosaic ZIP
#'   for a given year (2000–2022).
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
