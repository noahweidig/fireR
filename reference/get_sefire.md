# Download Southeast FireMap Annual Burn Severity Mosaics

Downloads one or more Southeast FireMap (SE FireMap) Annual Burn
Severity Mosaic ZIP archives from the USGS to a local directory. If a
ZIP already exists and `overwrite = FALSE`, no network call is made for
that year.

## Usage

``` r
get_sefire(
  years,
  directory = getwd(),
  overwrite = FALSE,
  timeout = 3600,
  verbose = TRUE
)
```

## Arguments

- years:

  `integer` vector of years to download. Accepts a single year (`2020`),
  a contiguous range created with `:` notation (`2010:2015`), or a
  vector of specific years (`c(2000, 2010, 2020)`). All values must be
  between `2000` and `2022` (inclusive). Duplicate years are silently
  ignored.

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

## Value

`character` vector of paths to the downloaded ZIP files (returned
invisibly). The length equals the number of unique years requested.

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
# Single year
zip_path <- get_sefire(2010)

# Contiguous range (2015 through 2020)
zip_paths <- get_sefire(2015:2020, directory = "data/sefire")

# Specific years only
zip_paths <- get_sefire(c(2000, 2010, 2020))
} # }
```
