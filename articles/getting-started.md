# Getting Started with fireR

## Overview

**fireR** provides two functions for [Monitoring Trends in Burn Severity
(MTBS)](https://www.mtbs.gov/) wildfire perimeter data:
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
downloads the ZIP archive, and
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
reads and filters it into a ready-to-analyse object.

``` r
library(fireR)
```

------------------------------------------------------------------------

## Basic usage

### All fires

With `output = "sf"`,
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
returns an **`sf`** object containing every fire perimeter in the MTBS
composite dataset — all years, all states.

``` r
fires <- read_mtbs(output = "sf")
fires
#> Simple feature collection with 31,386 features and 22 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -178.3 ymin: 17.9 xmax: -65.3 ymax: 71.4
#> CRS:           NAD83 / Conus Albers (EPSG:5070)
```

Plot the burn area acreage to get a quick sense of the data:

``` r
plot(fires["BurnBndAc"], main = "MTBS Fire Perimeters — All Years")
```

------------------------------------------------------------------------

## Filtering by year

### Single year

Pass a single integer to keep only fires that started in that calendar
year:

``` r
fires_2020 <- read_mtbs(years = 2020, output = "sf")
nrow(fires_2020)
#> [1] 246
```

### Year range

Supply a two-element vector to keep all fires within an inclusive span:

``` r
fires_recent <- read_mtbs(years = c(2018, 2023), output = "sf")
nrow(fires_recent)
#> [1] 1 328
```

Quickly visualise where the major fires of the last decade fell:

``` r
library(sf)

plot(st_geometry(fires_recent), col = "#E25822AA", border = NA,
     main = "MTBS Fire Perimeters 2018–2023")
```

------------------------------------------------------------------------

## Output formats

### terra::SpatVector

Set `output = "vect"` (or `"terra"`) to receive a
[`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
instead of an `sf` object — handy when the rest of your workflow uses
**terra**:

``` r
library(terra)

fires_vect <- read_mtbs(years = c(2020, 2023), output = "vect")
class(fires_vect)
#> [1] "SpatVector"
#> attr(,"package")
#> [1] "terra"

plot(fires_vect, "BurnBndAc", main = "Recent Fire Perimeters (terra)")
```

### Attribute table only

Set `geometry = FALSE` to drop geometry and get a plain `data.frame`.
Useful when you only need the metadata (fire name, year, acreage, etc.):

``` r
tbl <- read_mtbs(geometry = FALSE)
head(tbl[, c("Incid_Name", "Ig_Date", "BurnBndAc", "Incid_Type")])
#>     Incid_Name   Ig_Date BurnBndAc Incid_Type
#> 1  LOWDEN FIRE 1984-07-01   4537.35   Wildfire
#> 2  EUREKA FIRE 1984-08-15  11202.06   Wildfire
#> ...
```

------------------------------------------------------------------------

## Caching downloads

The MTBS ZIP archive is ~100 MB. Download it once with
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md),
then read from disk with
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
on every subsequent call.

### Default cache directory

Pass `cache = TRUE` to
[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
to look for the ZIP in `tools::R_user_dir("fireR", "cache")` — a
platform-appropriate user directory that persists between R sessions:

``` r
# Download once to the user cache directory
get_mtbs(directory = tools::R_user_dir("fireR", "cache"))

# Read from cache on every subsequent call
fires <- read_mtbs(cache = TRUE)
```

### Custom cache directory

Supply a directory path to both functions to control where the file is
stored:

``` r
get_mtbs(directory = "~/data/mtbs_cache")
fires <- read_mtbs(cache = "~/data/mtbs_cache")
```

### Force a fresh download

If the USGS releases an updated dataset, use `overwrite = TRUE` on
[`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
to bypass the cache and re-download:

``` r
get_mtbs(directory = tools::R_user_dir("fireR", "cache"), overwrite = TRUE)
fires <- read_mtbs(cache = TRUE)
```

------------------------------------------------------------------------

## Quiet mode

Progress messages are printed by default. Suppress them with
`verbose = FALSE`:

``` r
fires <- read_mtbs(years = 2022, verbose = FALSE)
```

------------------------------------------------------------------------

## Working with the data

Once you have an `sf` object, the full **sf** and **dplyr** ecosystem is
available to you.

### Key MTBS columns

| Column       | Description                                     |
|--------------|-------------------------------------------------|
| `Incid_Name` | Name of the fire event                          |
| `Ig_Date`    | Ignition date (YYYY-MM-DD)                      |
| `BurnBndAc`  | Burned area in acres                            |
| `Incid_Type` | Incident type (Wildfire, Prescribed Fire, etc.) |
| `irwinID`    | Unique IRWIN identifier                         |
| `geometry`   | Fire perimeter polygon(s)                       |

### Example: largest fires since 2000

``` r
library(dplyr)

fires_2000s <- read_mtbs(years = c(2000, 2023), output = "sf")

top10 <- fires_2000s |>
  slice_max(BurnBndAc, n = 10) |>
  select(Incid_Name, Ig_Date, BurnBndAc) |>
  st_drop_geometry()

top10
```

### Example: area burned and fires per year

``` r
library(dplyr)
library(ggplot2)
library(sf)

fires_all <- read_mtbs(output = "sf")
```

``` r
fires_all |>
  st_drop_geometry() |>
  mutate(year = as.integer(substr(Ig_Date, 1, 4))) |>
  group_by(year) |>
  summarize(area_burned = sum(BurnBndAc)) |>
  ggplot(aes(year, area_burned)) +
  geom_col(fill = "#8B1A1A") +
  labs(title = "Area Burned by Year",
       x = "Year",
       y = "Area Burned (Acres)") +
  theme_classic()
```

``` r
fires_all |>
  st_drop_geometry() |>
  mutate(year = as.integer(substr(Ig_Date, 1, 4))) |>
  count(year) |>
  ggplot(aes(year, n)) +
  geom_col(fill = "#8B1A1A") +
  labs(title = "Number of Fires by Year",
       x = "Year",
       y = "Number of Fires") +
  theme_classic()
```

------------------------------------------------------------------------

## About MTBS

The **Monitoring Trends in Burn Severity** programme is a joint USGS /
USFS initiative that maps the location, extent, and burn severity of all
large wildfires (\>1 000 acres in the western US; \>500 acres in the
eastern US) across the conterminous USA, Alaska, Hawaii, and Puerto Rico
from **1984 to the present**.

More information: <https://www.mtbs.gov/>
