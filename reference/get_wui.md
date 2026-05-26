# Download and unzip USFS Wildland-Urban Interface (WUI) data

Downloads the USFS Wildland-Urban Interface (WUI) dataset ZIP from the
USFS public Box archive and unzips it to a local directory. If the ZIP
already exists and `overwrite = FALSE`, no network call is made.

## Usage

``` r
get_wui(directory = getwd(), overwrite = FALSE, timeout = 3600, verbose = TRUE)
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

## Value

`character(1)` path to the downloaded ZIP file (invisibly).

## Warning \[large file\]

The WUI ZIP archive is approximately **4.65 GB**. Downloads are slow and
may take tens of minutes depending on connection speed. It is strongly
recommended to source this function in a background R session (e.g. with
[`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html)) so your
interactive session remains responsive.

## About USFS WUI

The Wildland-Urban Interface (WUI) dataset produced by the US Forest
Service delineates areas where structures and human development meet or
intermingle with undeveloped wildland vegetation. The WUI is a critical
planning layer for fire risk assessment, fuels management, and community
preparedness. Data are sourced from the USFS public archive hosted on
Box.

## Examples

``` r
if (FALSE) { # \dontrun{
# Recommended: run in a background session (4.65 GB download)
bg <- callr::r_bg(function() fireR::get_wui(directory = "data/wui"))
bg$wait()

# Download to the current directory
zip_path <- get_wui()

# Download to a specific directory
zip_path <- get_wui(directory = "data/wui")
} # }
```
