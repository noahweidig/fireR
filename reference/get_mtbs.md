# Download MTBS perimeter data

Downloads the MTBS composite burned-area extent ZIP archive to a
directory. If the ZIP already exists and `overwrite = FALSE`, no network
call is made.

## Usage

``` r
download_mtbs(
  url =
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
  directory = getwd(),
  overwrite = FALSE,
  retries = 3L,
  timeout = 300L,
  verbose = TRUE
)

get_mtbs(
  url =
    "https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip",
  directory = getwd(),
  overwrite = FALSE,
  retries = 3L,
  timeout = 300L,
  verbose = TRUE
)
```

## Arguments

- url:

  `character(1)` URL of the MTBS perimeter ZIP archive.

- directory:

  `character(1)` directory where `mtbs_perimeter_data.zip` is stored.

- overwrite:

  `logical(1)` re-download when `TRUE`; defaults to `FALSE`.

- retries:

  `integer(1)` number of download retry attempts.

- timeout:

  `integer(1)` timeout in seconds for each download attempt.

- verbose:

  `logical(1)` print progress messages.

## Value

`character(1)` path to the downloaded ZIP file (invisibly).

## Details

`get_mtbs()` is a convenience wrapper for `download_mtbs()`.

## Examples

``` r
if (FALSE) { # \dontrun{
mtbs_dir <- download_mtbs()
} # }
```
