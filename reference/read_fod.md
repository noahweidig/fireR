# Read USFS Fire Occurrence Database (FOD) data

Reads the USFS Fire Occurrence Database (FPA-FOD) from a local ZIP
downloaded with
[`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
and returns either a spatial object or a plain attribute table.

## Usage

``` r
read_fod(
  years = NULL,
  geometry = TRUE,
  output = c("vect", "sf", "terra"),
  cache = FALSE,
  verbose = TRUE
)
```

## Arguments

- years:

  `integer` vector of years to keep. Accepts a single year (`2015`), a
  contiguous range created with `:` notation (`2010:2020`), or a vector
  of specific years (`c(2000, 2010, 2020)`). Only fires whose
  `FIRE_YEAR` appears in `years` are returned. `NULL` (the default)
  returns all years without filtering.

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
  or `"sf"` for an `sf` object. Ignored when `geometry = FALSE`. Note
  this default (`"vect"`) intentionally differs from the ecoregion
  loaders
  ([`get_nal1eco`](https://noahweidig.github.io/fireR/reference/get_nal1eco.md),
  etc.), which default to `"sf"`; pass `output` explicitly for a
  consistent object class across functions.

- cache:

  `logical(1)` or `character(1)`. Controls where `read_fod()` looks for
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

`read_fod()` does not download data. Use
[`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
first to obtain the GeoPackage ZIP archive.

The ZIP contains a GeoPackage with a single `Fires` layer covering
1992–2020. Year filtering uses the integer `FIRE_YEAR` column.

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_fod()
fires <- read_fod(output = "sf")

# Single year
fires_2015 <- read_fod(years = 2015, output = "sf")

# Range of years
fires_recent <- read_fod(years = 2015:2020, output = "sf")

# Specific years only
fires_sel <- read_fod(years = c(2000, 2010, 2020), output = "sf")

# Attribute table only (no geometry)
tbl <- read_fod(geometry = FALSE)
} # }
```
