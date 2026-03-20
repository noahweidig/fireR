# Download MTBS perimeter data

Downloads the MTBS composite burned-area extent ZIP archive to a
directory. If the ZIP already exists and `overwrite = FALSE`, no network
call is made.

## Usage

``` r
get_mtbs(
  directory = getwd(),
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- directory:

  `character(1)` directory where `mtbs_perimeter_data.zip` is stored.
  Defaults to the current working directory.

- overwrite:

  `logical(1)` re-download when `TRUE`; defaults to `FALSE`.

- verbose:

  `logical(1)` print progress messages.

## Value

`character(1)` path to the downloaded ZIP file (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
zip_path <- get_mtbs()
} # }
```
