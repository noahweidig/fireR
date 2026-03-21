# Changelog

## fireR 1.0.0

### Initial stable release

- [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md):
  Download MTBS perimeter or occurrence ZIP archives from USGS.
- [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md):
  Read and filter MTBS fire perimeter records as `sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  objects, with optional year and incident-type filtering via
  server-side SQL queries.
- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md):
  Download Southeast FireMap Annual Burn Severity Mosaic ZIP archives
  for one or more years (2000–2022).
- [`get_nal1eco()`](https://noahweidig.github.io/fireR/reference/get_nal1eco.md),
  [`get_nal2eco()`](https://noahweidig.github.io/fireR/reference/get_nal2eco.md),
  [`get_nal3eco()`](https://noahweidig.github.io/fireR/reference/get_nal3eco.md):
  Load CEC North America ecoregion boundaries at Levels 1–3 as `sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  objects.
- [`get_usl3eco()`](https://noahweidig.github.io/fireR/reference/get_usl3eco.md),
  [`get_usl4eco()`](https://noahweidig.github.io/fireR/reference/get_usl4eco.md):
  Load US EPA ecoregion boundaries at Levels 3–4 (with optional state
  boundaries) as `sf` or
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  objects.
