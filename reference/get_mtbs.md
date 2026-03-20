# Download and Load MTBS Fire Perimeter Data

Downloads the MTBS composite burned-area extent shapefile from the USGS,
unzips it, and returns fire perimeters as a spatial object. Downloads
are performed using `curl`'s multi-handle for maximum throughput.

## Usage

``` r
get_mtbs(
  url =
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
  years = NULL,
  return_spatial = TRUE,
  output = c("sf", "vect", "terra"),
  cache = FALSE,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- url:

  `character(1)` URL of the MTBS perimeter ZIP archive. Defaults to the
  official USGS composite data endpoint.

- years:

  `integer` vector of length 1 or 2 specifying the year range to keep.
  If a single year is supplied, only fires from that year are returned.
  If two years are supplied they are treated as
  `c(start_year, end_year)` (inclusive). `NULL` (the default) returns
  all years without filtering.

- return_spatial:

  `logical(1)` When `TRUE` (the default) the result is a spatial object
  (`sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  depending on `output`). When `FALSE` the shapefile attributes are
  returned as a plain `data.frame` with the geometry column dropped.

- output:

  `character(1)` The class of the returned spatial object. Either `"sf"`
  (default) or `"vect"` / `"terra"` for a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html).
  Ignored when `return_spatial = FALSE`.

- cache:

  `logical(1)` or `character(1)`. When `FALSE` (the default) the ZIP is
  downloaded to a per-session temporary directory and deleted when the R
  session ends. When `TRUE` the file is cached in
  `tools::R_user_dir("fireR", "cache")` so subsequent calls skip the
  download entirely. Alternatively, supply a directory path as a string
  to control the cache location yourself.

- overwrite:

  `logical(1)` When `cache` is enabled, set `TRUE` to force a fresh
  download even if a cached copy exists. Defaults to `FALSE`.

- verbose:

  `logical(1)` Print progress messages. Defaults to `TRUE`.

## Value

- An `sf` object when `output = "sf"` and `return_spatial = TRUE`.

- A
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  when `output = "vect"` / `"terra"` and `return_spatial = TRUE`.

- A `data.frame` when `return_spatial = FALSE`.

## Details

### Speed

[`curl::curl_download()`](https://jeroen.r-universe.dev/curl/reference/curl_download.html)
is used in preference to base
[`download.file()`](https://rdrr.io/r/utils/download.file.html) because
the `curl` back-end uses a persistent HTTP/2 connection and avoids the
overhead of spawning an external process. For very large files you can
squeeze out additional throughput by setting the `CURL_CA_BUNDLE`
environment variable to point at a local CA bundle so TLS handshakes are
faster.

### Year filtering

Filtering is applied to the `Year` column that MTBS includes in the
attribute table. If the column cannot be found the raw data are returned
with a warning.

## Examples

``` r
if (FALSE) { # \dontrun{
# Default: all years, return as sf
fires <- get_mtbs()

# Only fires from 2020 to 2023, as a terra SpatVector
fires_recent <- get_mtbs(years = c(2020, 2023), output = "vect")

# Single year
fires_2020 <- get_mtbs(years = 2020)

# Attribute table only (no geometry)
tbl <- get_mtbs(return_spatial = FALSE)

# Cache the download for future sessions
fires <- get_mtbs(cache = TRUE)
} # }
```
