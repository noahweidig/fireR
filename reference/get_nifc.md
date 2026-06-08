# Download and unzip NIFC wildfire data

Downloads the NIFC (National Interagency Fire Center) wildfire
perimeters dataset from figshare and unzips it to a local directory. If
the ZIP already exists and `overwrite = FALSE`, no network call is made.

## Usage

``` r
get_nifc(
  directory = getwd(),
  overwrite = FALSE,
  timeout = 3600,
  verbose = TRUE,
  dry_run = FALSE
)
```

## Arguments

- directory:

  `character(1)` directory where the ZIP file and unzipped contents are
  stored. Defaults to the current working directory.

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

`character(1)` path to the downloaded ZIP file (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_nifc()
zip_path <- get_nifc(directory = "data/nifc")
} # }
```
