# Skip helper: checks if the USGS MTBS endpoint is actually reachable and
# able to serve data. Uses a Range GET (first 1 KB) rather than a HEAD
# request because some servers accept HEAD but restrict actual downloads.
skip_if_usgs_unreachable <- function(
    url = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip"
) {
  reachable <- tryCatch({
    h <- curl::new_handle(
      range          = "bytes=0-1023",
      timeout        = 15L,
      followlocation = TRUE,
      ssl_verifypeer = 1L
    )
    res <- curl::curl_fetch_memory(url, handle = h)
    res$status_code %in% c(200L, 206L)
  }, error = function(e) FALSE)

  if (!reachable) {
    skip("USGS MTBS endpoint is not reachable from this environment.")
  }
}

# Skip helper for the NIFC figshare endpoint.
skip_if_nifc_unreachable <- function(
    url = "https://ndownloader.figshare.com/files/38766504"
) {
  reachable <- tryCatch({
    h <- curl::new_handle(
      range          = "bytes=0-1023",
      timeout        = 15L,
      followlocation = TRUE,
      ssl_verifypeer = 1L
    )
    res <- curl::curl_fetch_memory(url, handle = h)
    res$status_code %in% c(200L, 206L)
  }, error = function(e) FALSE)

  if (!reachable) {
    skip("NIFC figshare endpoint is not reachable from this environment.")
  }
}


# Skip helper for downloaded NIFC archives that are reachable but unusable.
skip_if_invalid_nifc_archive <- function(
    directory,
    zip_name = "nifc_perimeters.zip"
) {
  zip_file <- file.path(directory, zip_name)
  zip_contents <- tryCatch(
    suppressWarnings(utils::unzip(zip_file, list = TRUE)),
    error = function(e) NULL
  )

  has_data_file <- !is.null(zip_contents) && any(grepl(
    "\\.gpkg$|\\.shp$|\\.gdb(/|$)",
    zip_contents$Name,
    ignore.case = TRUE
  ))

  if (!has_data_file) {
    skip("NIFC figshare download does not contain a readable spatial data file.")
  }
}

# Skip helper for the USFS FOD endpoint.
skip_if_fod_unreachable <- function(
    url = "https://www.fs.usda.gov/rds/archive/products/RDS-2013-0009.6/RDS-2013-0009.6_Data_Format3_GPKG.zip"
) {
  reachable <- tryCatch({
    h <- curl::new_handle(
      range          = "bytes=0-1023",
      timeout        = 15L,
      followlocation = TRUE,
      ssl_verifypeer = 1L,
      useragent      = paste0(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
        "AppleWebKit/537.36 (KHTML, like Gecko) ",
        "Chrome/124.0.0.0 Safari/537.36"
      )
    )
    res <- curl::curl_fetch_memory(url, handle = h)
    res$status_code %in% c(200L, 206L)
  }, error = function(e) FALSE)

  if (!reachable) {
    skip("USFS FOD endpoint is not reachable from this environment.")
  }
}
