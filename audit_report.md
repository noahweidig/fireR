# Audit Report: fireR Package

## 1. Must fix

None found. The package is generally well-structured, passes R CMD check
without errors/warnings/notes, and handles dependencies and large
downloads appropriately (e.g., using `cli_warn` for large files and
robust caching).

## 2. Safe improvements

- **Missing tests for argument validation:** The `dry_run` parameter was
  recently added to all `get_*` functions (which is good practice for
  large downloads). While the
  [`is.logical()`](https://rdrr.io/r/base/logical.html) argument
  validation exists in the source code (e.g., in `R/get_mtbs.R`,
  `R/get_nifc.R`, etc.), the corresponding `testthat` blocks validating
  that incorrect input types (like “yes”, NA, or vectors of length \> 1)
  throw proper errors are missing in the test files.
- *Action:* Add `expect_error` tests for the `dry_run` argument across
  `test-get_eco.R`, `test-get_mtbs.R`, `test-get_nifc.R`,
  `test-get_sefire.R`, and `test-get_wui.R`.

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
