# Read MTBS fire perimeter data

Reads MTBS fire perimeters from locally extracted data and returns
either a spatial object or a plain attribute table. Data are
downloaded/unzipped via
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
when needed.

## Usage

``` r
read_mtbs(
  url =
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
  years = NULL,
  type = NULL,
  geometry = TRUE,
  output = c("vect", "sf", "terra"),
  cache = FALSE,
  overwrite = FALSE,
  retries = 3L,
  timeout = 300L,
  verbose = TRUE
)
```

## Arguments

- url:

  `character(1)` URL of the MTBS perimeter ZIP archive.

- years:

  `integer` vector of length 1 or 2 specifying the year range to keep.
  If a single year is supplied, only fires from that year are returned.
  If two years are supplied they are treated as
  `c(start_year, end_year)` (inclusive). `NULL` (the default) returns
  all years without filtering.

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
  or `"sf"` for an `sf` object. Ignored when `geometry = FALSE`.

- cache:

  `logical(1)` or `character(1)`. When `FALSE` (the default) data are
  downloaded/extracted in a per-session temporary directory. When `TRUE`
  data are cached in `tools::R_user_dir("fireR", "cache")`.
  Alternatively, supply a directory path as a string to control the
  location.

- overwrite:

  `logical(1)` force re-download and re-extraction.

- retries:

  `integer(1)` number of download retry attempts.

- timeout:

  `integer(1)` timeout in seconds per download attempt.

- verbose:

  `logical(1)` print progress messages.

## Value

- A
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  when `output = "vect"` / `"terra"` and `geometry = TRUE`.

- An `sf` object when `output = "sf"` and `geometry = TRUE`.

- A `data.frame` when `geometry = FALSE`.

## Examples

``` r
if (FALSE) { # \dontrun{
fires <- read_mtbs()
fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")
tbl <- read_mtbs(geometry = FALSE)
} # }
```
