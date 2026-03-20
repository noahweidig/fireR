#' fireR: Fast Access to MTBS, SE FireMap, and Ecoregion Data
#'
#' @description `fireR` provides ergonomic entry points for USGS fire data and
#' EPA/CEC ecoregion boundaries:
#' [get_mtbs()] and [read_mtbs()] for MTBS (Monitoring Trends in Burn
#' Severity) composite burned-area extent data, [get_sefire()] for
#' Southeast FireMap Annual Burn Severity Mosaics, and a family of ecoregion
#' loaders ([get_nal1eco()], [get_nal2eco()], [get_nal3eco()],
#' [get_usl3eco()], [get_usl4eco()]) for CEC North America and US EPA
#' ecoregion boundaries.  Spatial results can be returned as an
#' [`sf`][sf::sf] object, a [`terra::SpatVector`][terra::vect], or a plain
#' `data.frame`.
#'
#' @section Main functions:
#' * [get_mtbs()] — download MTBS fire perimeter ZIP data.
#' * [read_mtbs()] — read, filter, and return MTBS fire perimeters.
#' * [get_sefire()] — download SE FireMap Annual Burn Severity Mosaic ZIP(s)
#'   for one or more years (2000–2022).
#' * [get_nal1eco()] — download and load North America Level 1 Ecoregions.
#' * [get_nal2eco()] — download and load North America Level 2 Ecoregions.
#' * [get_nal3eco()] — download and load North America Level 3 Ecoregions.
#' * [get_usl3eco()] — download and load US Level 3 Ecoregions.
#' * [get_usl4eco()] — download and load US Level 4 Ecoregions.
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
