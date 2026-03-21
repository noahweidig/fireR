# fireR 1.0.0

## Initial stable release

* `get_mtbs()`: Download MTBS perimeter or occurrence ZIP archives from USGS.
* `read_mtbs()`: Read and filter MTBS fire perimeter records as `sf` or `terra::SpatVector` objects, with optional year and incident-type filtering via server-side SQL queries.
* `get_sefire()`: Download Southeast FireMap Annual Burn Severity Mosaic ZIP archives for one or more years (2000–2022).
* `get_nal1eco()`, `get_nal2eco()`, `get_nal3eco()`: Load CEC North America ecoregion boundaries at Levels 1–3 as `sf` or `terra::SpatVector` objects.
* `get_usl3eco()`, `get_usl4eco()`: Load US EPA ecoregion boundaries at Levels 3–4 (with optional state boundaries) as `sf` or `terra::SpatVector` objects.
