# fireR <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/noahweidig/fireR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/noahweidig/fireR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/noahweidig/fireR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/noahweidig/fireR/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

> Fast access to MTBS (Monitoring Trends in Burn Severity) fire perimeter data,
> SE FireMap burn severity mosaics, USFS Wildland-Urban Interface (WUI) data,
> and EPA/CEC ecoregion boundaries straight from the source.

## Overview

`fireR` provides convenient access to USGS fire datasets and EPA/CEC ecoregion
boundaries:

- `get_mtbs()` downloads the MTBS ZIP to a directory
- `read_mtbs()` reads, filters, and returns data from that ZIP as **`sf`**,
  **`terra::SpatVector`**, or `data.frame`
- `get_sefire()` downloads SE FireMap Annual Burn Severity Mosaic ZIP(s) for
  one or more years (2000–2022)
- `get_nal1eco()` / `get_nal2eco()` / `get_nal3eco()` — download and load CEC
  North America ecoregions at Levels 1–3
- `get_usl3eco()` / `get_usl4eco()` — download and load US EPA ecoregions at
  Levels 3–4 (with optional state boundaries)
- `get_nifc()` / `read_nifc()` — download and read NIFC (National Interagency
  Fire Center) wildfire perimeters from figshare, with optional year filtering
- `get_fod()` / `read_fod()` — download and read the USFS Fire Occurrence
  Database (FPA-FOD) GeoPackage from the Forest Service Research Data Archive,
  with optional year filtering
- `get_wui()` — download the USFS Wildland-Urban Interface (WUI) dataset
  from the USFS public Box archive (**4.65 GB** — slow, run in the background)

Key features:

- ⚡ **Fast downloads** — uses `curl`'s HTTP/2 persistent connection
- 🗓️ **Flexible year filtering** — single year (`2020`), range (`2010:2020`),
  or specific years (`c(2000, 2010, 2020)`)
- 🗺️ **Flexible output** — `sf`, `terra`, or plain `data.frame`
- 💾 **Optional caching** — skip the download on repeat calls

---

## Installation

```r
# Install from GitHub (once published)
# install.packages("pak")
pak::pak("noahweidig/fireR")
```

---

## Usage

### All fires, return as `sf`

```r
library(fireR)

# Download the data first (caches locally)
get_mtbs()

fires <- read_mtbs(output = "sf")
plot(fires["BurnBndAc"])
```

### Filter to a year range

```r
fires_recent <- read_mtbs(years = 2010:2023, output = "sf")
```

### Single year

```r
fires_2020 <- read_mtbs(years = 2020, output = "sf")
```

### Specific years only

```r
fires_sel <- read_mtbs(years = c(2000, 2010, 2020), output = "sf")
```

### Return as `terra::SpatVector`

```r
fires_vect <- read_mtbs(years = 2015:2023, output = "vect")
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

## SE FireMap

Download burn severity mosaics for one or more years:

```r
# Single year
zip_path <- get_sefire(2020)

# Contiguous range
zip_paths <- get_sefire(2015:2020, directory = "data/sefire")

# Specific years
zip_paths <- get_sefire(c(2000, 2010, 2020))
```

---

## NIFC Wildfire Perimeters

Download and read the NIFC wildfire perimeters dataset from figshare.  Year
filtering uses the integer `FireYear` column.

```r
# Download to current directory
zip_path <- get_nifc()

# Read all perimeters as sf
perims <- read_nifc(output = "sf")

# Filter to a single year
perims_2020 <- read_nifc(years = 2020, output = "sf")

# Filter to a range of years
perims_recent <- read_nifc(years = 2015:2020, output = "sf")

# Cache the download for future sessions
perims <- read_nifc(cache = TRUE)
```

---

## USFS Fire Occurrence Database (FOD)

Download and read the FPA-FOD GeoPackage ZIP from the Forest Service Research
Data Archive.  The dataset covers 1992–2020; year filtering uses the integer
`FIRE_YEAR` column.

```r
# Download to current directory
zip_path <- get_fod()

# Read all fire occurrence points as sf
fires <- read_fod(output = "sf")

# Filter to a single year
fires_2015 <- read_fod(years = 2015, output = "sf")

# Filter to a range of years
fires_recent <- read_fod(years = 2015:2020, output = "sf")

# Attribute table only (no geometry)
tbl <- read_fod(geometry = FALSE)
```

---

## USFS Wildland-Urban Interface (WUI)

> **Warning:** The WUI ZIP is approximately **4.65 GB** and will be slow to
> download.  It is strongly recommended to run `get_wui()` in a background R
> session so your interactive session remains responsive.

```r
# Recommended: run in a background session
bg <- callr::r_bg(function() fireR::get_wui(directory = "data/wui"))
bg$wait()

# Or download to the current directory (blocks the session)
zip_path <- get_wui()

# Download to a specific directory
zip_path <- get_wui(directory = "data/wui")
```

---

## Ecoregions

### North America (CEC Levels 1–3)

```r
# Level 1 — broadest continental divisions
na_l1 <- get_nal1eco()

# Level 2 — finer continental subdivisions
na_l2 <- get_nal2eco()

# Level 3 — finest continental scale (= US EPA Level III)
na_l3 <- get_nal3eco(output = "vect")
```

### US EPA (Levels 3–4, with optional state boundaries)

```r
# Level 3 — without state boundaries (default)
us_l3 <- get_usl3eco()

# Level 3 — with state boundaries
us_l3_states <- get_usl3eco(state = TRUE)

# Level 4 — finest US subdivisions
us_l4 <- get_usl4eco()
us_l4_states <- get_usl4eco(state = TRUE)
```

All ecoregion functions accept `output = "sf"` (default) or `output = "vect"`
and a `cache` argument to persist downloads between sessions.

---

## `read_mtbs()` Arguments

| Argument | Type | Default | Description |
|---|---|---|---|
| `years` | `integer` | `NULL` | Single year, range (`2010:2020`), or specific years (`c(2000, 2010)`). `NULL` = no filter |
| `type` | `character` | `NULL` | Incident type(s). `NULL` = all types |
| `geometry` | `logical` | `TRUE` | Return a spatial object. `FALSE` → `data.frame` |
| `output` | `character` | `"vect"` | `"sf"` or `"vect"` / `"terra"` |
| `cache` | `logical`/`character` | `FALSE` | Directory containing the downloaded ZIP |
| `verbose` | `logical` | `TRUE` | Print progress messages |

Download data to disk first with `get_mtbs()`:

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
