# Skip helper: checks if the USGS MTBS endpoint is actually reachable.
# skip_if_offline() only verifies general internet connectivity; the USGS
# server can be unreachable (firewall, CDN outage, CI network policy) even
# when the internet is up.
skip_if_usgs_unreachable <- function(
    url = "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip"
) {
  reachable <- tryCatch({
    h <- curl::new_handle(nobody = TRUE, timeout = 10L, followlocation = TRUE)
    res <- curl::curl_fetch_memory(url, handle = h)
    res$status_code < 400L
  }, error = function(e) FALSE)

  if (!reachable) {
    skip("USGS MTBS endpoint is not reachable from this environment.")
  }
}
