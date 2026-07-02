# Changelog

## fireR 1.1.0

### New functions

- [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md):
  Download the NIFC wildfire perimeters ZIP from figshare and unzip to a
  local directory.
- [`read_nifc()`](https://noahweidig.github.io/fireR/reference/read_nifc.md):
  Read and filter NIFC wildfire perimeters from a local ZIP downloaded
  with
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md).
  Supports year filtering via the integer `FireYear` column, and returns
  `sf`,
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
  or `data.frame`.
- [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md):
  Download the USFS Fire Occurrence Database (FPA-FOD) GeoPackage ZIP
  and unzip to a local directory.
- [`read_fod()`](https://noahweidig.github.io/fireR/reference/read_fod.md):
  Read and filter the USFS Fire Occurrence Database (FPA-FOD) from a
  local ZIP downloaded with
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md).
  Supports year filtering via the integer `FIRE_YEAR` column (dataset
  covers 1992–2020), and returns `sf`,
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html),
  or `data.frame`.

------------------------------------------------------------------------

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
- [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md):
  Download the USFS Wildland-Urban Interface (WUI) dataset ZIP (~4.65
  GB) from the USFS public Box archive. Issues a warning that the
  download is large and slow, and recommends running in a background
  session via
  [`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html).
