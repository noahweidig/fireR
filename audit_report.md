# Audit Report: fireR Package

## 1. Must fix

None found. The package is extremely stable, passes R CMD check
flawlessly with 0 errors/warnings/notes, correctly manages namespaces,
properly handles caching logic, and has a strong test suite validating
its exported functions.

## 2. Safe improvements

- **Test coverage for `dry_run` bounds:** While `test-get_sefire.R`
  comprehensively checks `dry_run` for the `"Burn Severity"` and
  `"Fire History"` datasets, it omits identical assertions for
  `"Burned Area Polygons"` and `"Burned Area Rasters"`.
  - *Action:* Add `dry_run` tests for the two remaining datasets in
    `tests/testthat/test-get_sefire.R` to ensure complete coverage.
- **Large download warnings:** The
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md),
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md),
  and
  [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  functions properly warn users before initiating multi-gigabyte or
  multi-hundred-megabyte network downloads using
  [`cli::cli_warn`](https://cli.r-lib.org/reference/cli_abort.html).
  However,
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
  (the USFS Fire Occurrence Database GeoPackage) downloads a ~100MB+ ZIP
  archive without warning the user.
  - *Action:* Add a `@section Warning \[large files\]:` block in the
    roxygen documentation for
    [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md),
    and add a corresponding
    [`cli::cli_warn`](https://cli.r-lib.org/reference/cli_abort.html)
    block prior to download execution in `R/get_nifc.R` to match the
    package convention for large files.

## 3. Possible features, but defer unless needed

- **Inconsistent output defaults:** The `read_*` functions (`read_mtbs`,
  `read_nifc`, `read_fod`) default to `output = "vect"` (which returns a
  [`terra::SpatVector`](https://rspatial.github.io/terra/reference/SpatVector-class.html)),
  whereas the `get_eco` functions (`get_nal1eco`, `get_usl3eco`, etc.)
  default to `output = "sf"`. Unifying the default across all functions
  to `"sf"` might make the package more coherent, but would be a
  backward-incompatible breaking change. Defer unless explicitly
  requested.

## 4. Do not touch

- **Package Architecture & Namespace:** The current `roxygen2`-generated
  `NAMESPACE` and file structure (`R/`, `man/`, `tests/`) are clean and
  functional. Do not manually edit.
- **pkgdown Configuration:** The `_pkgdown.yml` file correctly lists all
  exported functions in logical groups, uses Bootstrap 5, and includes
  the necessary GitHub Pages workflow components.
- **Large Download Tests:** The functions triggering heavy downloads
  correctly use `\dontrun{}` in examples, and the `testthat` suite
  properly leverages `skip_on_cran()` and `dry_run` to avoid
  overwhelming CI environments. Do not modify these safeguards.
- **Branding:** The logo and custom theming must be strictly preserved.
