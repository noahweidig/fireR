# fireR: Fast Access to MTBS Fire Perimeter Data

`fireR` provides two ergonomic entry points for MTBS (Monitoring Trends
in Burn Severity) composite burned-area extent data:
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
for downloading, and
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
for reading and filtering data as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object, a
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/vect.html),
or a plain `data.frame`.

## Main functions

- [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  — download MTBS fire perimeter ZIP data.

- [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
  — read, filter, and return MTBS fire perimeters.

## See also

Useful links:

- <https://github.com/noahweidig/fireR>

- Report bugs at <https://github.com/noahweidig/fireR/issues>

## Author

**Maintainer**: Noah Weidig <noah.weidig@ufl.edu>
