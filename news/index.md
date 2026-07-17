# Changelog

## fireR 1.1.0

### Bug fixes

- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  now inspects the
  [`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
  return value and emits a warning for any failed year downloads instead
  of printing “Downloads complete.” unconditionally
  ([\#111](https://github.com/noahweidig/fireR/issues/111)).
- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md),
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md),
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md),
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md),
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md),
  and the ecoregion loaders now delete any partial or zero-byte file
  left on disk after a failed download, so that a subsequent call
  re-downloads correctly instead of treating the partial file as
  already-complete
  ([\#122](https://github.com/noahweidig/fireR/issues/122),
  [\#125](https://github.com/noahweidig/fireR/issues/125),
  [\#128](https://github.com/noahweidig/fireR/issues/128),
  [\#129](https://github.com/noahweidig/fireR/issues/129)).
- [`read_nifc()`](https://noahweidig.github.io/fireR/reference/read_nifc.md)
  now checks that
  [`sf::st_layers()`](https://r-spatial.github.io/sf/reference/st_layers.html)
  returns at least one layer and emits an actionable error message if
  the file is corrupt or empty instead of throwing “subscript out of
  bounds” ([\#118](https://github.com/noahweidig/fireR/issues/118)).
- [`read_fod()`](https://noahweidig.github.io/fireR/reference/read_fod.md)
  now discovers the GeoPackage layer name dynamically via
  [`sf::st_layers()`](https://r-spatial.github.io/sf/reference/st_layers.html)
  instead of hardcoding `"Fires"`, matching
  [`read_nifc()`](https://noahweidig.github.io/fireR/reference/read_nifc.md)
  and providing a clear error if the file is unreadable
  ([\#137](https://github.com/noahweidig/fireR/issues/137)).
- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  “years ignored” warning now fires unconditionally for
  non-Burn-Severity datasets regardless of `verbose`; previously
  `verbose = FALSE` silently suppressed it
  ([\#121](https://github.com/noahweidig/fireR/issues/121)).
- Vignette corrected: MTBS ZIP is ~360 MB, not ~100 MB
  ([\#119](https://github.com/noahweidig/fireR/issues/119)).
- `output` default asymmetry between
  [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)/[`read_nifc()`](https://noahweidig.github.io/fireR/reference/read_nifc.md)/[`read_fod()`](https://noahweidig.github.io/fireR/reference/read_fod.md)
  (`"vect"`) and the ecoregion loaders (`"sf"`) is now documented in
  each reader’s `@param output`
  ([\#120](https://github.com/noahweidig/fireR/issues/120)).

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

### New features

- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  gains a `dataset` argument. In addition to the annual Burn Severity
  mosaics (2000–2022), it now downloads three single-file SE FireMap
  products covering 1994–2024: `"Fire History"`,
  `"Burned Area Polygons"`, and `"Burned Area Rasters"`.
- `dry_run = FALSE` added to
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md),
  [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md),
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md),
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md),
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md),
  and the ecoregion loaders. When `TRUE`, the target file path is
  returned without triggering a network request — useful for previewing
  cache locations before starting large downloads.

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
