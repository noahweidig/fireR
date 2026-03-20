# Download Southeast FireMap Annual Burn Severity Mosaic

Downloads a single-year Southeast FireMap (SE FireMap) Annual Burn
Severity Mosaic ZIP archive from the USGS to a local directory. If the
ZIP already exists and `overwrite = FALSE`, no network call is made.

## Usage

``` r
get_sefire(
  year,
  directory = getwd(),
  overwrite = FALSE,
  timeout = 3600,
  verbose = TRUE
)
```

## Arguments

- year:

  `integer(1)` the year of the mosaic to download. Must be a single
  value between `2000` and `2022` (inclusive).

- directory:

  `character(1)` directory where the ZIP file is saved. Defaults to the
  current working directory.

- overwrite:

  `logical(1)` re-download when `TRUE`; defaults to `FALSE`.

- timeout:

  `numeric(1)` download timeout in seconds. Defaults to `3600` (one
  hour).

- verbose:

  `logical(1)` print progress messages.

## Value

`character(1)` path to the downloaded ZIP file (invisibly).

## Details

The southeastern United States experiences frequent wild and prescribed
fire activity. The USGS developed a gradient-boosted decision tree model
trained on over 5,000 Composite Burn Inventory (CBI) field plots to
predict post-fire burn severity as a CBI value (0–3) across the region.
The model ingests ARD Landsat predictors capturing first- and
second-order fire effects, climate norms, and fire seasonality, then
applies the trained model to the extent of burned area identified by the
Landsat Burned Area Product. The result is an annual burn severity
mosaic covering 78 ARD Landsat tiles across the southeastern United
States for years 2000–2022. These mosaics improve characterisation of
burn severity—including small and prescribed fires that are
under-represented in national datasets—and support estimation of
fire-related emissions, fuel loads, aboveground carbon storage, and land
management activities.

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_sefire(2010)
zip_path <- get_sefire(2020, directory = "data/sefire")
} # }
```
