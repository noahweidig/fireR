# Download and Load MTBS Fire Perimeter Data

Downloads the MTBS composite burned-area extent shapefile from the USGS,
unzips it, and returns fire perimeters as a spatial object. The
shapefile is read via `terra` (significantly faster than `sf` for large
files) and converted to `sf` only when requested. Year and type
filtering is performed via an OGR SQL query so only matching features
are read into memory.

## Usage

``` r
get_mtbs(
  url =
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
  years = NULL,
  type = NULL,
  geometry = TRUE,
  output = c("vect", "sf", "terra"),
  cache = FALSE,
  overwrite = FALSE,
  verbose = TRUE,
  method = c("curl", "wget"),
  background = FALSE
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
  all years without filtering. Filtering is based on the `Ig_Date`
  column (format `YYYY-MM-DD`) via OGR SQL.

- type:

  `character` vector of incident types to keep, matched against the
  `Incid_Type` column. Valid values are `"Wildfire"`,
  `"Prescribed Fire"`, `"Unknown"`, `"Wildland Fire Use"`, and
  `"Complex"`. `NULL` (the default) returns all incident types.

- geometry:

  `logical(1)` When `TRUE` (the default) the result is a spatial object
  (`sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  depending on `output`). When `FALSE` the shapefile attributes are
  returned as a plain `data.frame` with the geometry column dropped.

- output:

  `character(1)` The class of the returned spatial object. Either
  `"vect"` / `"terra"` (default) for a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
  or `"sf"` for an `sf` object. Defaulting to `"vect"` avoids the
  overhead of converting to `sf` when it is not needed. Ignored when
  `geometry = FALSE`.

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

- method:

  `character(1)` Download back-end. `"curl"` (default) uses
  [`curl::curl_download()`](https://jeroen.r-universe.dev/curl/reference/curl_download.html)
  with an HTTP/2 persistent connection. `"wget"` delegates to the system
  `wget` executable via
  [`download.file()`](https://rdrr.io/r/utils/download.file.html) and
  may be faster on systems where `wget` is installed and tuned. Falls
  back to `"curl"` with a warning if `wget` is not found on `PATH`.

- background:

  `logical(1)` When `TRUE` the download (and all subsequent processing)
  runs in a background R process via
  [`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html), so
  your interactive session stays responsive. The function returns a
  `callr` process object immediately; call `$wait()` to block until it
  finishes and `$get_result()` to retrieve the spatial object. Requires
  the callr package. Defaults to `FALSE`.

## Value

- When `background = FALSE` (default):

  - A
    [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
    when `output = "vect"` / `"terra"` and `geometry = TRUE`.

  - An `sf` object when `output = "sf"` and `geometry = TRUE`.

  - A `data.frame` when `geometry = FALSE`.

- When `background = TRUE`: a `callr` `r_process` object. Use `$wait()`
  then `$get_result()` to obtain the spatial object.

## Details

### Speed

Three design decisions keep this function fast:

1.  **[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
    is the default output** (`output = "vect"`). The `terra` C++ layer
    reads shapefiles substantially faster than
    [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
    and skipping the
    [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html)
    conversion saves additional time. Pass `output = "sf"` explicitly
    when you need an `sf` object.

2.  **[`curl::curl_download()`](https://jeroen.r-universe.dev/curl/reference/curl_download.html)**
    is used in preference to base
    [`download.file()`](https://rdrr.io/r/utils/download.file.html)
    because the `curl` back-end uses a persistent HTTP/2 connection,
    avoids spawning an external process, and never times out on large
    files (the handle is configured with `timeout = 0`). Pass
    `method = "wget"` to delegate to the system `wget` instead.

3.  **OGR SQL filtering** is applied at read time via
    [`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html),
    so only matching features are loaded into memory.

### Non-blocking download

Pass `background = TRUE` to keep your R session responsive while the
~100 MB archive downloads:

    proc <- get_mtbs(years = 2020, background = TRUE)
    # ... do other work ...
    proc$wait()
    fires <- proc$get_result()

`background = TRUE` requires the callr package
(`install.packages("callr")`).

### Year and type filtering

Filtering is performed as an OGR SQL `WHERE` clause passed directly to
[`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html),
so only matching features are read into memory. Years are matched
against the `Ig_Date` column (e.g. `1997-04-23`); incident types are
matched against the `Incid_Type` column.

## Examples

``` r
if (FALSE) { # \dontrun{
# Default: all years, return as terra SpatVector (fastest)
fires <- get_mtbs()

# Only fires from 2020 to 2023
fires_recent <- get_mtbs(years = c(2020, 2023))

# Single year, wildfires only, as sf
fires_2020 <- get_mtbs(years = 2020, type = "Wildfire", output = "sf")

# Attribute table only (no geometry)
tbl <- get_mtbs(geometry = FALSE)

# Cache the download for future sessions
fires <- get_mtbs(cache = TRUE)

# Non-blocking: download in background, keep working
proc <- get_mtbs(years = 2020, background = TRUE)
proc$wait()
fires <- proc$get_result()

# Use system wget instead of curl
fires <- get_mtbs(method = "wget")
} # }
```
