# Download and load North America Level 3 Ecoregions

Downloads and loads the Commission for Environmental Cooperation (CEC)
North America Level 3 Ecoregion boundaries as a spatial object.

## Usage

``` r
get_nal3eco(
  output = c("sf", "vect", "terra"),
  cache = FALSE,
  verbose = TRUE
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

- verbose:

  `logical(1)` print progress messages.

## Value

An `sf` object or
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
of North America Level 3 Ecoregion polygons.

## Details

The Commission for Environmental Cooperation (CEC) North American
ecoregion framework divides the continent into hierarchical levels based
on similarity of ecosystems and the type, quality, and quantity of
environmental resources. Level 3 provides the finest continental-scale
subdivisions, corresponding to the US EPA Level III ecoregions. Data are
sourced from the US EPA / CEC ecoregion mapping programme.

## Examples

``` r
if (FALSE) { # \dontrun{
eco <- get_nal3eco()
eco_terra <- get_nal3eco(output = "vect")
} # }
```
