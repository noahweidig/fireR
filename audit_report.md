# Audit Report: fireR Package

## 1. Must fix

- None found. The package is stable, passes R CMD check, correctly
  manages namespaces, properly handles caching logic, and has a strong
  test suite validating its exported functions.

## 2. Safe improvements

- **Large download warnings:** The
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md),
  [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md)
  and
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
  functions properly document large file warnings in their Roxygen
  blocks. However,
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  downloads a ZIP archive of hundreds of megabytes without an explicit
  `@section Warning \[large files\]:` in its Roxygen documentation.
  Furthermore, while
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
  is documented with this warning in `R/get_nifc.R`, the README lacks
  corresponding warning blocks for both MTBS and FOD.
  - *Action:* Add `@section Warning \[large files\]:` to
    [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
    in `R/get_mtbs.R`. Add explicit block quote warnings
    (`> **Warning:**`) for
    [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
    and
    [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md)
    in `README.md` to match the package convention for SE FireMap and
    WUI.

## 3. Possible features, but defer unless needed

- **Inconsistent output defaults:** The `read_*` functions (`read_mtbs`,
  `read_nifc`, `read_fod`) default to `output = "vect"`, whereas the
  `get_eco` functions default to `output = "sf"`. Unifying the default
  across all functions to `"sf"` might make the package more coherent,
  but would be a backward-incompatible breaking change. Defer unless
  explicitly requested.

## 4. Do not touch

- **Package Architecture & Namespace:** The current `roxygen2`-generated
  `NAMESPACE` and file structure (`R/`, `man/`, `tests/`) are clean and
  functional. Do not manually edit.
- **pkgdown Configuration:** The `_pkgdown.yml` file correctly lists all
  exported functions in logical groups, uses Bootstrap 5, and includes
  the necessary GitHub Pages workflow components.
- **Branding:** The logo and custom theming must be strictly preserved.
- **Existing Test Logic for Large Downloads:** The `testthat` suite
  properly leverages `skip_on_cran()` and `dry_run` to avoid
  overwhelming CI environments. Do not modify these safeguards.
