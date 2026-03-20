# Read MTBS fire perimeter data

Reads MTBS fire perimeters from a local MTBS ZIP downloaded with
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
and returns either a spatial object or a plain attribute table.

## Usage

``` r
read_mtbs(
  years = NULL,
  type = NULL,
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
  of specific years (`c(2000, 2010, 2020)`). Only fires whose ignition
  year appears in `years` are returned. `NULL` (the default) returns all
  years without filtering.

- type:

  `character` vector of incident types to keep, matched against the
  `Incid_Type` column. Valid values are `"Wildfire"`,
  `"Prescribed Fire"`, `"Unknown"`, and `"Wildland Fire Use"`. `NULL`
  (the default) returns all incident types.

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

  `logical(1)` or `character(1)`. Controls where `read_mtbs()` looks for
  the downloaded ZIP file. When `FALSE` (the default) the current
  working directory is used. When `TRUE` the platform user cache
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

`read_mtbs()` does not download data. Use
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
first to obtain the ZIP archive.

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_mtbs()
fires <- read_mtbs(output = "sf")

# Single year
fires_2020 <- read_mtbs(years = 2020, type = "Wildfire", output = "sf")

# Contiguous range
fires_recent <- read_mtbs(years = 2018:2023, output = "sf")

# Specific years only
fires_sel <- read_mtbs(years = c(2010, 2015, 2020), output = "sf")

tbl <- read_mtbs(geometry = FALSE)
} # }
```
