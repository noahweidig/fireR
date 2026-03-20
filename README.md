# fireR <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/noahweidig/fireR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/noahweidig/fireR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/noahweidig/fireR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/noahweidig/fireR/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

> Fast access to MTBS (Monitoring Trends in Burn Severity) fire perimeter data
> straight from the USGS.

## Overview

`fireR` splits MTBS access into two functions:

- `get_mtbs()` downloads the MTBS ZIP to a directory
- `read_mtbs()` reads, filters, and returns data from that ZIP as **`sf`**,
  **`terra::SpatVector`**, or `data.frame`

Key features:

- ⚡ **Fast downloads** — uses `curl`'s HTTP/2 persistent connection
- 🗓️ **Year filtering** — `years = c(1986, 2020)` keeps only fires within that
  span
- 🗺️ **Flexible output** — `sf`, `terra`, or plain `data.frame`
- 💾 **Optional caching** — skip the download on repeat calls

---

## Installation

```r
# Install from GitHub (once published)
# install.packages("pak")
pak::pak("noahweidig/fireR")
```

During development, install with:

```r
devtools::install()    # run from the package root
```

---

## Usage

### All fires, return as `sf`

```r
library(fireR)

fires <- read_mtbs(output = "sf")
plot(fires["BurnBndAc"])
```

### Filter to a year range

```r
fires_recent <- read_mtbs(years = c(2010, 2023), output = "sf")
```

### Single year

```r
fires_2020 <- read_mtbs(years = 2020, output = "sf")
```

### Return as `terra::SpatVector`

```r
fires_vect <- read_mtbs(years = c(2015, 2023), output = "vect")
```

### Attribute table only (no geometry)

```r
tbl <- read_mtbs(geometry = FALSE)
```

### Cache the download for future sessions

```r
# Cache in the default user directory
fires <- read_mtbs(cache = TRUE)

# Or supply your own cache path
fires <- read_mtbs(cache = "~/data/mtbs_cache")
```

---

## `read_mtbs()` Arguments

| Argument | Type | Default | Description |
|---|---|---|---|
| `url` | `character` | USGS URL | Source ZIP URL |
| `years` | `integer` | `NULL` | Year range `c(start, end)` or single year. `NULL` = no filter |
| `geometry` | `logical` | `TRUE` | Return a spatial object. `FALSE` → `data.frame` |
| `output` | `character` | `"vect"` | `"sf"` or `"vect"` / `"terra"` |
| `cache` | `logical`/`character` | `FALSE` | Cache the ZIP file across sessions |
| `overwrite` | `logical` | `FALSE` | Force fresh download even if cached copy exists |
| `verbose` | `logical` | `TRUE` | Print progress messages |

To only download data to disk:

```r
mtbs_dir <- get_mtbs()
```

---

## About MTBS

[Monitoring Trends in Burn Severity (MTBS)](https://www.mtbs.gov/) is a
multi-agency programme (USGS, USFS) that maps the location, extent, and burn
severity of all large wildfires across the conterminous USA, Alaska, Hawaii, and
Puerto Rico from 1984 to the present.

---

## License

MIT © Noah Weidig
