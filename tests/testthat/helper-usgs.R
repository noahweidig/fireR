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
