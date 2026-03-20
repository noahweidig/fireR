# fireR: Fast Access to MTBS, SE FireMap, and Ecoregion Data

`fireR` provides ergonomic entry points for USGS fire data and EPA/CEC
ecoregion boundaries:
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
and
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
for MTBS (Monitoring Trends in Burn Severity) composite burned-area
extent data,
[`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
for Southeast FireMap Annual Burn Severity Mosaics, and a family of
ecoregion loaders
([`get_nal1eco()`](https://noahweidig.github.io/fireR/reference/get_nal1eco.md),
[`get_nal2eco()`](https://noahweidig.github.io/fireR/reference/get_nal2eco.md),
[`get_nal3eco()`](https://noahweidig.github.io/fireR/reference/get_nal3eco.md),
[`get_usl3eco()`](https://noahweidig.github.io/fireR/reference/get_usl3eco.md),
[`get_usl4eco()`](https://noahweidig.github.io/fireR/reference/get_usl4eco.md))
for CEC North America and US EPA ecoregion boundaries. Spatial results
can be returned as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object, a
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/vect.html),
or a plain `data.frame`.

## Main functions

- [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  — download MTBS fire perimeter ZIP data.

- [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
  — read, filter, and return MTBS fire perimeters.

- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  — download SE FireMap Annual Burn Severity Mosaic ZIP(s) for one or
  more years (2000–2022).

- [`get_nal1eco()`](https://noahweidig.github.io/fireR/reference/get_nal1eco.md)
  — download and load North America Level 1 Ecoregions.

- [`get_nal2eco()`](https://noahweidig.github.io/fireR/reference/get_nal2eco.md)
  — download and load North America Level 2 Ecoregions.

- [`get_nal3eco()`](https://noahweidig.github.io/fireR/reference/get_nal3eco.md)
  — download and load North America Level 3 Ecoregions.

- [`get_usl3eco()`](https://noahweidig.github.io/fireR/reference/get_usl3eco.md)
  — download and load US Level 3 Ecoregions.

- [`get_usl4eco()`](https://noahweidig.github.io/fireR/reference/get_usl4eco.md)
  — download and load US Level 4 Ecoregions.

## See also

Useful links:

- <https://github.com/noahweidig/fireR>

- Report bugs at <https://github.com/noahweidig/fireR/issues>

## Author

**Maintainer**: Noah Weidig <noah.weidig@ufl.edu>
