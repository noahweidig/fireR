# Download and unzip USFS Fire Occurrence Database (FOD)

Downloads the USFS Fire Occurrence Database (FPA-FOD) GeoPackage ZIP
archive from the Forest Service Research Data Archive and unzips it to a
local directory. The server requires browser-like request headers, so
httr2 is used instead of a simple download helper. If the ZIP already
exists and `overwrite = FALSE`, no network call is made.

## Usage

``` r
get_fod(
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
zip_path <- get_fod()
zip_path <- get_fod(directory = "data/fod")
} # }
```
