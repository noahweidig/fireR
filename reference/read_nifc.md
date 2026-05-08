# Read NIFC wildfire perimeter data

Reads NIFC wildfire perimeters from a local NIFC ZIP downloaded with
[`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md)
and returns either a spatial object or a plain attribute table.

## Usage

``` r
read_nifc(
  years = NULL,
  geometry = TRUE,
  output = c("vect", "sf", "terra"),
  cache = FALSE,
  verbose = TRUE
)
```

## Arguments

- years:

  `integer` vector of years to keep. Accepts a single year (`2020`), a
  contiguous range created with `:` notation (`2010:2020`), or a vector
  of specific years (`c(2000, 2010, 2020)`). Only fires whose `FireYear`
  appears in `years` are returned. `NULL` (the default) returns all
  years without filtering.

- geometry:

  `logical(1)` When `TRUE` (the default) the result is a spatial object
  (`sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  depending on `output`). When `FALSE` the attributes are returned as a
  plain `data.frame`.

- output:

  `character(1)` The class of the returned spatial object. Either
  `"vect"` / `"terra"` (default) for a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
  or `"sf"` for an `sf` object. Ignored when `geometry = FALSE`.

- cache:

  `logical(1)` or `character(1)`. Controls where `read_nifc()` looks for
  the downloaded ZIP file. When `FALSE` (the default), the current
  working directory is used. When `TRUE`, the platform user cache
  directory (`tools::R_user_dir("fireR", "cache")`) is used. Supply a
  directory path as a string to specify a custom location.

- verbose:

  `logical(1)` print progress messages.

## Value

- A
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  when `output = "vect"` / `"terra"` and `geometry = TRUE`.

- An `sf` object when `output = "sf"` and `geometry = TRUE`.

- A `data.frame` when `geometry = FALSE`.

## Details

`read_nifc()` does not download data. Use
[`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md)
first to obtain the perimeters ZIP archive.

The ZIP is expected to contain either a GeoPackage (`.gpkg`) or a
shapefile (`.shp`). Year filtering uses the integer `FireYear` column
present in the NIFC historical perimeters data.

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_nifc()
perims <- read_nifc(output = "sf")

# Single year
perims_2020 <- read_nifc(years = 2020, output = "sf")

# Contiguous range
perims_recent <- read_nifc(years = 2015:2020, output = "sf")

# Specific years only
perims_sel <- read_nifc(years = c(2010, 2015, 2020), output = "sf")

# Attribute table only (no geometry)
tbl <- read_nifc(geometry = FALSE)
} # }
```
