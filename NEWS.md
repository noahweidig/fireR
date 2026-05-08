# fireR 1.1.0

## New functions

* `read_nifc()`: Read and filter NIFC wildfire perimeters from a local ZIP
  downloaded with `get_nifc()`. Supports year filtering via the integer
  `FireYear` column, and returns `sf`, `terra::SpatVector`, or `data.frame`.
* `read_fod()`: Read and filter the USFS Fire Occurrence Database (FPA-FOD)
  from a local ZIP downloaded with `get_fod()`. Supports year filtering via
  the integer `FIRE_YEAR` column (dataset covers 1992–2020), and returns `sf`,
  `terra::SpatVector`, or `data.frame`.

---

# fireR 1.0.0

## Initial stable release

* `get_mtbs()`: Download MTBS perimeter or occurrence ZIP archives from USGS.
* `read_mtbs()`: Read and filter MTBS fire perimeter records as `sf` or `terra::SpatVector` objects, with optional year and incident-type filtering via server-side SQL queries.
* `get_sefire()`: Download Southeast FireMap Annual Burn Severity Mosaic ZIP archives for one or more years (2000–2022).
* `get_nal1eco()`, `get_nal2eco()`, `get_nal3eco()`: Load CEC North America ecoregion boundaries at Levels 1–3 as `sf` or `terra::SpatVector` objects.
* `get_usl3eco()`, `get_usl4eco()`: Load US EPA ecoregion boundaries at Levels 3–4 (with optional state boundaries) as `sf` or `terra::SpatVector` objects.
* `get_wui()`: Download the USFS Wildland-Urban Interface (WUI) dataset ZIP (~4.65 GB) from the USFS public Box archive.  Issues a warning that the download is large and slow, and recommends running in a background session via `callr::r_bg()`.
