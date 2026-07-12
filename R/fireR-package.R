#' fireR: Fast Access to MTBS, SE FireMap, and Ecoregion Data
#'
#' @description `fireR` provides ergonomic entry points for USGS fire data and
#' EPA/CEC ecoregion boundaries:
#' [get_mtbs()] and [read_mtbs()] for MTBS (Monitoring Trends in Burn
#' Severity) composite burned-area extent data, [get_sefire()] for SE
#' FireMap data products (annual Burn Severity Mosaics for 2000-2022, plus
#' single-file Fire History, Burned Area Polygons, and Burned Area Rasters
#' covering 1994-2024), [get_nifc()] and
#' [read_nifc()] for NIFC wildfire perimeters, [get_fod()] and [read_fod()]
#' for the USFS Fire Occurrence Database (FPA-FOD), [get_wui()] for the USFS
#' Wildland-Urban Interface dataset, and a family of ecoregion
#' loaders ([get_nal1eco()], [get_nal2eco()], [get_nal3eco()],
#' [get_usl3eco()], [get_usl4eco()]) for CEC North America and US EPA
#' ecoregion boundaries.  Spatial results can be returned as an
#' [`sf`][sf::sf] object, a [`terra::SpatVector`][terra::vect], or a plain
#' `data.frame`.
#'
#' @section Main functions:
#' * [get_mtbs()] - download MTBS fire perimeter ZIP data.
#' * [read_mtbs()] - read, filter, and return MTBS fire perimeters.
#' * [get_sefire()] - download SE FireMap data products: annual Burn Severity
#'   Mosaic ZIP(s) for one or more years (2000-2022), or single-file Fire
#'   History, Burned Area Polygons, and Burned Area Rasters datasets
#'   (1994-2024).
#' * [get_nifc()] - download NIFC wildfire perimeters data.
#' * [read_nifc()] - read, filter, and return NIFC wildfire perimeters.
#' * [get_fod()] - download USFS Fire Occurrence Database (FOD) data.
#' * [read_fod()] - read, filter, and return FOD fire occurrences.
#' * [get_wui()] - download the USFS Wildland-Urban Interface (WUI) dataset.
#' * [get_nal1eco()] - download and load North America Level 1 Ecoregions.
#' * [get_nal2eco()] - download and load North America Level 2 Ecoregions.
#' * [get_nal3eco()] - download and load North America Level 3 Ecoregions.
#' * [get_usl3eco()] - download and load US Level 3 Ecoregions.
#' * [get_usl4eco()] - download and load US Level 4 Ecoregions.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom fs dir_create file_exists file_delete path
#' @importFrom cli cli_inform cli_warn
#' @importFrom curl curl_download multi_download new_handle
#' @importFrom rlang arg_match
#' @importFrom sf st_as_sf st_layers
#' @importFrom terra vect values
## usethis namespace: end
NULL

## Shared curl configuration --------------------------------------------------

.ua_string <- paste0(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
  "AppleWebKit/537.36 (KHTML, like Gecko) ",
  "Chrome/124.0.0.0 Safari/537.36"
)
