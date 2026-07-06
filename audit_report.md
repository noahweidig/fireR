# Audit Report: fireR Package

## 1. Must fix

None found. The package is generally well-structured, passes R CMD check
without errors/warnings/notes, and handles dependencies and large
downloads appropriately (e.g., using `cli_warn` for large files and
robust caching).

## 2. Safe improvements

- **Missing tests for argument validation:** Some exported functions in
  `get_eco.R` lack tests for parameter validation in
  `tests/testthat/test-get_eco.R`. Specifically, `get_nal2eco`,
  `get_nal3eco`, and `get_usl4eco` are missing `verbose` argument
  validation tests, and `get_usl4eco` is missing `state` argument
  validation tests. In addition, `read_mtbs` in `test-get_mtbs.R` lacks
  thorough `geometry` argument validation tests (missing NA and numeric
  cases compared to `read_nifc` and `read_fod`).
- *Action:* Add `expect_error` tests for `verbose` validation across
  `get_nal2eco`, `get_nal3eco`, and `get_usl4eco`, for `state`
  validation in `get_usl4eco`, and for `geometry = NA` and
  `geometry = 1` in `read_mtbs`.
- **Minor test coverage improvements:** The test coverage is excellent,
  and previous checks for `state`, `cache`, and `verbose` arguments in
  `get_eco.R` were already in place. However, a few functions are
  missing explicit tests for `timeout` in `test-get_eco.R`.
  Specifically, `get_usl3eco` missing `NA_real_` and `get_usl4eco`
  missing negative timeout validation checks.
- *Action:* Add `expect_error` tests for `timeout` validation in
  `get_usl3eco` and `get_usl4eco`.

## 3. Possible features, but defer unless needed

- **Inconsistent output defaults:** The `read_*` functions (`read_mtbs`,
  `read_nifc`, `read_fod`) default to `output = "vect"` (which returns a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)),
  whereas the `get_eco` functions (`get_nal1eco`, `get_usl3eco`, etc.)
  default to `output = "sf"`. Furthermore, the `README.md` and
  `getting-started.Rmd` vignette consistently specify `output = "sf"` in
  examples, treating it almost as the intended default. While unifying
  the default across all functions to `"sf"` might make the package more
  coherent, this would be a backward-incompatible change. Per the
  conservative review constraints (“Do not change default behavior
  unless it fixes a clear bug”), this should be deferred.

## 4. Do not touch

- **Package Architecture & Namespace:** The current `roxygen2`-generated
  `NAMESPACE` and file structure (`R/`, `man/`, `tests/`) are clean and
  functional. Do not manually edit.
- **pkgdown Configuration:** The `_pkgdown.yml` file correctly lists all
  exported functions in logical groups, uses Bootstrap 5, and includes
  the necessary GitHub Pages workflow components. Leave as-is.
- **Large Download Examples:** The examples using functions that trigger
  heavy downloads (e.g., `get_wui`, `get_sefire` for large years)
  correctly use `\dontrun{}` and the `testthat` suite properly leverages
  `skip_on_cran()` and `dry_run` features to avoid overwhelming CI
  environments. Do not modify these safeguards.
- **Branding:** The logo and custom theming (e.g., `pkgdown` colors)
  should not be changed.
