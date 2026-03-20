# Download and load US Level 4 Ecoregions

Downloads and loads US EPA Level 4 Ecoregion boundaries as a spatial
object, optionally including state boundaries.

## Usage

``` r
get_usl4eco(
  state = FALSE,
  output = c("sf", "vect", "terra"),
  cache = FALSE,
  verbose = TRUE
)
```

## Arguments

- state:

  `logical(1)` when `TRUE`, the dataset with state boundaries dissolved
  into the ecoregion polygons is returned. Defaults to `FALSE`.

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

- verbose:

  `logical(1)` print progress messages.

## Value

An `sf` object or
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
of US Level 4 Ecoregion polygons.

## Details

The US EPA ecoregion framework classifies areas of the United States by
similarity of ecosystems and environmental resources. Level 4 provides
the finest sub-divisions in the US ecoregion hierarchy, capturing local
ecological patterns within Level 3 regions. These are commonly used for
site-level assessments and detailed environmental monitoring. Data are
sourced from the US EPA Office of Research and Development.

## Examples

``` r
if (FALSE) { # \dontrun{
eco <- get_usl4eco()
eco_state <- get_usl4eco(state = TRUE)
eco_terra <- get_usl4eco(output = "vect")
} # }
```
