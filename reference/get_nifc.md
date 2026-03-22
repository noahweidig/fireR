# Download and unzip NIFC wildfire data

Downloads the NIFC (National Interagency Fire Center) wildfire
perimeters dataset from figshare and unzips it to a local directory. If
the ZIP already exists and `overwrite = FALSE`, no network call is made.

## Usage

``` r
get_nifc(
  directory = getwd(),
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- directory:

  `character(1)` directory where the ZIP file and unzipped contents are
  stored. Defaults to the current working directory.

- overwrite:

  `logical(1)` re-download when `TRUE`; defaults to `FALSE`.

- verbose:

  `logical(1)` print progress messages.

## Value

`character(1)` path to the downloaded ZIP file (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_nifc()
zip_path <- get_nifc(directory = "data/nifc")
} # }
```
