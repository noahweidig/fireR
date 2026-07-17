# fireR 1.1.0

## Bug fixes

* `get_sefire()` now inspects the `curl::multi_download()` return value and emits
  a warning for any failed year downloads instead of printing "Downloads complete."
  unconditionally (#111).
* `get_sefire()`, `get_mtbs()`, `get_nifc()`, `get_fod()`, `get_wui()`, and the
  ecoregion loaders now delete any partial or zero-byte file left on disk after a
  failed download, so that a subsequent call re-downloads correctly instead of
  treating the partial file as already-complete (#122, #125, #128, #129).
* `read_nifc()` now checks that `sf::st_layers()` returns at least one layer and
  emits an actionable error message if the file is corrupt or empty instead of
  throwing "subscript out of bounds" (#118).
* `read_fod()` now discovers the GeoPackage layer name dynamically via
  `sf::st_layers()` instead of hardcoding `"Fires"`, matching `read_nifc()` and
  providing a clear error if the file is unreadable (#137).
* `get_sefire()` "years ignored" warning now fires unconditionally for non-Burn-Severity
  datasets regardless of `verbose`; previously `verbose = FALSE` silently suppressed
  it (#121).
* Vignette corrected: MTBS ZIP is ~360 MB, not ~100 MB (#119).
* `output` default asymmetry between `read_mtbs()`/`read_nifc()`/`read_fod()`
  (`"vect"`) and the ecoregion loaders (`"sf"`) is now documented in each reader's
  `@param output` (#120).

## New functions

* `get_nifc()`: Download the NIFC wildfire perimeters ZIP from figshare and
  unzip to a local directory.
* `read_nifc()`: Read and filter NIFC wildfire perimeters from a local ZIP
  downloaded with `get_nifc()`. Supports year filtering via the integer
  `FireYear` column, and returns `sf`, `terra::SpatVector`, or `data.frame`.
* `get_fod()`: Download the USFS Fire Occurrence Database (FPA-FOD) GeoPackage
  ZIP and unzip to a local directory.
* `read_fod()`: Read and filter the USFS Fire Occurrence Database (FPA-FOD)
  from a local ZIP downloaded with `get_fod()`. Supports year filtering via
  the integer `FIRE_YEAR` column (dataset covers 1992–2020), and returns `sf`,
  `terra::SpatVector`, or `data.frame`.

## New features

* `get_sefire()` gains a `dataset` argument. In addition to the annual Burn
  Severity mosaics (2000–2022), it now downloads three single-file SE FireMap
  products covering 1994–2024: `"Fire History"`, `"Burned Area Polygons"`, and
  `"Burned Area Rasters"`.
* `dry_run = FALSE` added to `get_mtbs()`, `get_sefire()`, `get_nifc()`,
  `get_fod()`, `get_wui()`, and the ecoregion loaders. When `TRUE`, the target
  file path is returned without triggering a network request — useful for
  previewing cache locations before starting large downloads.

---

# fireR 1.0.0

## Initial stable release

* `get_mtbs()`: Download MTBS perimeter or occurrence ZIP archives from USGS.
* `read_mtbs()`: Read and filter MTBS fire perimeter records as `sf` or `terra::SpatVector` objects, with optional year and incident-type filtering via server-side SQL queries.
* `get_sefire()`: Download Southeast FireMap Annual Burn Severity Mosaic ZIP archives for one or more years (2000–2022).
* `get_nal1eco()`, `get_nal2eco()`, `get_nal3eco()`: Load CEC North America ecoregion boundaries at Levels 1–3 as `sf` or `terra::SpatVector` objects.
* `get_usl3eco()`, `get_usl4eco()`: Load US EPA ecoregion boundaries at Levels 3–4 (with optional state boundaries) as `sf` or `terra::SpatVector` objects.
* `get_wui()`: Download the USFS Wildland-Urban Interface (WUI) dataset ZIP (~4.65 GB) from the USFS public Box archive.  Issues a warning that the download is large and slow, and recommends running in a background session via `callr::r_bg()`.
