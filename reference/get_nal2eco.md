# Download and load North America Level 2 Ecoregions

Downloads and loads the Commission for Environmental Cooperation (CEC)
North America Level 2 Ecoregion boundaries as a spatial object.

## Usage

``` r
get_nal2eco(
  output = c("sf", "vect", "terra"),
  cache = FALSE,
  timeout = 3600,
  verbose = TRUE,
  dry_run = FALSE,
  overwrite = FALSE
)
```

## Arguments

- output:

  `character(1)` class of the returned spatial object. Either `"sf"`
  (default) or `"vect"` / `"terra"` for a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html).

- cache:

  `logical(1)` or `character(1)`. Controls where the ZIP is cached.
  `FALSE` (the default) uses a temporary directory that is cleaned up
  when the R session ends. `TRUE` uses the platform user cache directory
  (`tools::R_user_dir("fireR", "cache")`). Supply a directory path as a
  string to specify a custom location.

- timeout:

  `numeric(1)` download timeout in seconds. Default is `3600`.

- verbose:

  `logical(1)` print progress messages.

- dry_run:

  `logical(1)` if `TRUE`, do not download the file but instead return
  the path where it would be saved. Defaults to `FALSE`.

- overwrite:

  `logical(1)` re-download when `TRUE`, deleting any cached ZIP first;
  defaults to `FALSE`.

## Value

An `sf` object or
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
of North America Level 2 Ecoregion polygons. (Or the file path invisibly
if `dry_run = TRUE`).

## About CEC Ecoregions

The Commission for Environmental Cooperation (CEC) North American
ecoregion framework divides the continent into hierarchical levels based
on similarity of ecosystems and the type, quality, and quantity of
environmental resources. Level 2 subdivides the Level 1 regions into
finer ecological units. Data are sourced from the US EPA / CEC ecoregion
mapping programme.

## Examples

``` r
if (FALSE) { # \dontrun{
eco <- get_nal2eco()
eco_terra <- get_nal2eco(output = "vect")
} # }
```
