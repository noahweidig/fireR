# fireR

> Fast access to MTBS (Monitoring Trends in Burn Severity) fire
> perimeter data, SE FireMap burn severity mosaics, and EPA/CEC
> ecoregion boundaries straight from the source.

## Overview

`fireR` provides convenient access to USGS fire datasets and EPA/CEC
ecoregion boundaries:

- [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  downloads the MTBS ZIP to a directory
- [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
  reads, filters, and returns data from that ZIP as **`sf`**,
  **[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)**,
  or `data.frame`
- [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  downloads SE FireMap Annual Burn Severity Mosaic ZIP(s) for one or
  more years (2000–2022)
- [`get_nal1eco()`](https://noahweidig.github.io/fireR/reference/get_nal1eco.md)
  /
  [`get_nal2eco()`](https://noahweidig.github.io/fireR/reference/get_nal2eco.md)
  /
  [`get_nal3eco()`](https://noahweidig.github.io/fireR/reference/get_nal3eco.md)
  — download and load CEC North America ecoregions at Levels 1–3
- [`get_usl3eco()`](https://noahweidig.github.io/fireR/reference/get_usl3eco.md)
  /
  [`get_usl4eco()`](https://noahweidig.github.io/fireR/reference/get_usl4eco.md)
  — download and load US EPA ecoregions at Levels 3–4 (with optional
  state boundaries)
- [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md)
  — download NIFC (National Interagency Fire Center) wildfire perimeters
  dataset from figshare
- [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
  — download the USFS Fire Occurrence Database (FPA-FOD) GeoPackage ZIP
  from the Forest Service Research Data Archive

Key features:

- ⚡ **Fast downloads** — uses `curl`’s HTTP/2 persistent connection
- 🗓️ **Flexible year filtering** — single year (`2020`), range
  (`2010:2020`), or specific years (`c(2000, 2010, 2020)`)
- 🗺️ **Flexible output** — `sf`, `terra`, or plain `data.frame`
- 💾 **Optional caching** — skip the download on repeat calls

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub (once published)
# install.packages("pak")
pak::pak("noahweidig/fireR")
```

------------------------------------------------------------------------

## Usage

### All fires, return as `sf`

``` r
library(fireR)

fires <- read_mtbs(output = "sf")
plot(fires["BurnBndAc"])
```

### Filter to a year range

``` r
fires_recent <- read_mtbs(years = 2010:2023, output = "sf")
```

### Single year

``` r
fires_2020 <- read_mtbs(years = 2020, output = "sf")
```

### Specific years only

``` r
fires_sel <- read_mtbs(years = c(2000, 2010, 2020), output = "sf")
```

### Return as `terra::SpatVector`

``` r
fires_vect <- read_mtbs(years = 2015:2023, output = "vect")
```

### Attribute table only (no geometry)

``` r
tbl <- read_mtbs(geometry = FALSE)
```

### Cache the download for future sessions

``` r
# Cache in the default user directory
fires <- read_mtbs(cache = TRUE)

# Or supply your own cache path
fires <- read_mtbs(cache = "~/data/mtbs_cache")
```

------------------------------------------------------------------------

## SE FireMap

Download burn severity mosaics for one or more years:

``` r
# Single year
zip_path <- get_sefire(2020)

# Contiguous range
zip_paths <- get_sefire(2015:2020, directory = "data/sefire")

# Specific years
zip_paths <- get_sefire(c(2000, 2010, 2020))
```

------------------------------------------------------------------------

## NIFC Wildfire Perimeters

Download the NIFC wildfire perimeters dataset from figshare:

``` r
# Download to current directory
zip_path <- get_nifc()

# Download to a specific directory
zip_path <- get_nifc(directory = "data/nifc")
```

------------------------------------------------------------------------

## USFS Fire Occurrence Database (FOD)

Download the FPA-FOD GeoPackage ZIP from the Forest Service Research
Data Archive:

``` r
# Download to current directory
zip_path <- get_fod()

# Download to a specific directory
zip_path <- get_fod(directory = "data/fod")
```

------------------------------------------------------------------------

## Ecoregions

### North America (CEC Levels 1–3)

``` r
# Level 1 — broadest continental divisions
na_l1 <- get_nal1eco()

# Level 2 — finer continental subdivisions
na_l2 <- get_nal2eco()

# Level 3 — finest continental scale (= US EPA Level III)
na_l3 <- get_nal3eco(output = "vect")
```

### US EPA (Levels 3–4, with optional state boundaries)

``` r
# Level 3 — without state boundaries (default)
us_l3 <- get_usl3eco()

# Level 3 — with state boundaries
us_l3_states <- get_usl3eco(state = TRUE)

# Level 4 — finest US subdivisions
us_l4 <- get_usl4eco()
us_l4_states <- get_usl4eco(state = TRUE)
```

All ecoregion functions accept `output = "sf"` (default) or
`output = "vect"` and a `cache` argument to persist downloads between
sessions.

------------------------------------------------------------------------

## `read_mtbs()` Arguments

| Argument   | Type                  | Default  | Description                                                                               |
|------------|-----------------------|----------|-------------------------------------------------------------------------------------------|
| `years`    | `integer`             | `NULL`   | Single year, range (`2010:2020`), or specific years (`c(2000, 2010)`). `NULL` = no filter |
| `type`     | `character`           | `NULL`   | Incident type(s). `NULL` = all types                                                      |
| `geometry` | `logical`             | `TRUE`   | Return a spatial object. `FALSE` → `data.frame`                                           |
| `output`   | `character`           | `"vect"` | `"sf"` or `"vect"` / `"terra"`                                                            |
| `cache`    | `logical`/`character` | `FALSE`  | Directory containing the downloaded ZIP                                                   |
| `verbose`  | `logical`             | `TRUE`   | Print progress messages                                                                   |

Download data to disk first with
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md):

``` r
mtbs_dir <- get_mtbs()
```

------------------------------------------------------------------------

## About MTBS

[Monitoring Trends in Burn Severity (MTBS)](https://www.mtbs.gov/) is a
multi-agency programme (USGS, USFS) that maps the location, extent, and
burn severity of all large wildfires across the conterminous USA,
Alaska, Hawaii, and Puerto Rico from 1984 to the present.

------------------------------------------------------------------------

## License

MIT © Noah Weidig
