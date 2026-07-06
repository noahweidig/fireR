# Download Southeast FireMap Datasets

Downloads Southeast FireMap (SE FireMap) data products from the USGS and
the SE FireMap S3 archive to a local directory. Four `dataset` options
are available: annual Burn Severity mosaics (one ZIP per year), a
single-file Fire History map, Burned Area Polygons, or Burned Area
Rasters. If a ZIP already exists and `overwrite = FALSE`, no network
call is made.

## Usage

``` r
get_sefire(
  dataset = c("Burn Severity", "Fire History", "Burned Area Polygons",
    "Burned Area Rasters"),
  years = NULL,
  directory = getwd(),
  overwrite = FALSE,
  timeout = 3600,
  verbose = TRUE,
  dry_run = FALSE
)
```

## Arguments

- dataset:

  `character(1)` the SE FireMap product to download. One of
  `"Burn Severity"` (default), `"Fire History"`,
  `"Burned Area Polygons"`, or `"Burned Area Rasters"`.
  `"Burn Severity"` downloads one ZIP per year from USGS and requires
  the `years` argument. The remaining three products cover 1994–2024 as
  a single ZIP each and do not use `years`.

- years:

  `integer` vector of years to download. Used only when
  `dataset = "Burn Severity"`. Accepts a single year (`2020`), a
  contiguous range created with `:` notation (`2010:2015`), or a vector
  of specific years (`c(2000, 2010, 2020)`). All values must be between
  `2000` and `2022` (inclusive). Duplicate years are silently ignored.
  Ignored for all other datasets.

- directory:

  `character(1)` directory where the ZIP file(s) are saved. Defaults to
  the current working directory.

- overwrite:

  `logical(1)` re-download when `TRUE`; defaults to `FALSE`.

- timeout:

  `numeric(1)` download timeout in seconds. Defaults to `3600` (one
  hour).

- verbose:

  `logical(1)` print progress messages.

- dry_run:

  `logical(1)` if `TRUE`, do not download the file but instead return
  the path where it would be saved. Defaults to `FALSE`.

## Value

For `dataset = "Burn Severity"`: a `character` vector of paths to the
downloaded ZIP files (returned invisibly), one element per unique year
requested. For all other datasets: a `character(1)` path to the
downloaded ZIP file (returned invisibly).

## About SE FireMap

The southeastern United States experiences frequent wild and prescribed
fire activity. The USGS developed a gradient-boosted decision tree model
trained on over 5,000 Composite Burn Inventory (CBI) field plots to
predict post-fire burn severity as a CBI value (0–3) across the region.
The model ingests ARD Landsat predictors capturing first- and
second-order fire effects, climate norms, and fire seasonality, then
applies the trained model to the extent of burned area identified by the
Landsat Burned Area Product. The result is an annual burn severity
mosaic covering 78 ARD Landsat tiles across the southeastern United
States for years 2000–2022.

The SE FireMap Fall 2024 release additionally provides a Fire History
Map (1994–2024), Burned Area Polygons (1994–2024), and Burned Area
Raster grids (1994–2024) as single-file geodatabase ZIPs. Year selection
is not applicable to these three products; the `years` argument is
silently ignored when they are requested.

## Warning \[large files\]

The SE FireMap datasets can be very large. A single year of Burn
Severity data is approximately 50-100 MB, but downloading all 23 years
(2000–2022) at once requires several gigabytes. The single-file datasets
(Fire History, Burned Area Polygons, Burned Area Rasters) range from 1
to 3 GB each. Downloads may be slow; consider running in a background
session (e.g., with
[`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html)) to keep
your interactive session responsive.

## Examples

``` r
if (FALSE) { # \dontrun{
# Burn Severity -- single year
zip_path <- get_sefire(years = 2010)

# Burn Severity -- contiguous range (2015 through 2020)
zip_paths <- get_sefire(years = 2015:2020, directory = "data/sefire")

# Burn Severity -- specific years only
zip_paths <- get_sefire(years = c(2000, 2010, 2020))

# Fire History (1994-2024)
zip_path <- get_sefire(dataset = "Fire History", directory = "data/sefire")

# Burned Area Polygons (1994-2024)
zip_path <- get_sefire(dataset = "Burned Area Polygons", directory = "data/sefire")

# Burned Area Rasters (1994-2024)
zip_path <- get_sefire(dataset = "Burned Area Rasters", directory = "data/sefire")
} # }
```
