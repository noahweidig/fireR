# fireR: Fast Access to MTBS Fire Perimeter Data

`fireR` provides a single, ergonomic entry point —
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
— for downloading the MTBS (Monitoring Trends in Burn Severity)
composite burned- area extent shapefile published by the USGS. The
download uses `curl`'s persistent HTTP/2 connection for maximum
throughput. Results can be returned as an
[`sf`](https://r-spatial.github.io/sf/reference/sf.html) object, a
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/vect.html),
or a plain `data.frame`.

## Main functions

- [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  — download, unzip, and load MTBS fire perimeters.

## See also

Useful links:

- <https://github.com/noahweidig/fireR>

- Report bugs at <https://github.com/noahweidig/fireR/issues>

## Author

**Maintainer**: Noah Weidig <noah.weidig@ufl.edu>
