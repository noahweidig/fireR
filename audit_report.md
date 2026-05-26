# fireR Package Audit Report

## 1. Must fix

- No critical “must fix” bugs remain. (Prior issues regarding missing
  explicit input validation for `directory`, `overwrite`, `timeout`,
  `verbose`, and `state` across `get_*` and `read_*` functions were
  addressed in a recent commit).

## 2. Safe improvements

- **README Documentation**: The `dataset` parameter is missing from the
  “[`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
  Arguments” table in the README. It needs to be documented so users
  know they can select between `"perimeters"` and `"occurrence"`.
- **Test Coverage**: The test suite validates `dataset` for
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md),
  but it misses a test for invalid `dataset` arguments inside
  [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md).
  An assertion should be added to `tests/testthat/test-get_mtbs.R`.

## 3. Possible features, but defer unless needed

- Dry-run capability to list available datasets without downloading.
- Progress bar reporting instead of discrete messages.
- Exposing retry counts for HTTP requests.
- Additional explicit `is.character` and `!any(is.na())` checks for
  `type` filtering in
  [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md).
- No critical “must fix” issues exist in the current architecture.
  Explicit validation (`is.character`, `length() == 1L`, `!is.na()`,
  etc.) for `directory`, `overwrite`, `verbose`, and `state` are already
  correctly implemented across all exported functions, ensuring they
  fail fast with clear errors.

## 2. Safe improvements

- Explicitly add the `timeout` parameter to
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md),
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md),
  and
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md)
  to maintain parity with
  [`get_mtbs()`](https://noahweidig.github.io/fireR/reference/get_mtbs.md)
  and
  [`get_sefire()`](https://noahweidig.github.io/fireR/reference/get_sefire.md).
- Implement strict, explicit input validation for the newly added
  `timeout` parameter (`is.numeric`, `length() == 1L`, `!is.na()`,
  `timeout > 0`) in these three functions.
- Update `tests/testthat/test-get_nifc.R` and
  `tests/testthat/test-get_wui.R` with `expect_error()` checks asserting
  that invalid inputs for `timeout` are appropriately caught and
  rejected.
- Document the `timeout` parameter in the roxygen comments for
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md),
  [`get_fod()`](https://noahweidig.github.io/fireR/reference/get_fod.md),
  and
  [`get_wui()`](https://noahweidig.github.io/fireR/reference/get_wui.md).

## 3. Possible features, but defer unless needed

- Dry-run capability or a `list-available-years` helper to check
  available datasets without downloading.
- Progress bar reporting instead of discrete console messages.
- Exposing explicit retry counts and options for HTTP requests.

## 4. Do not touch

- The overall architecture of downloading to `cache_dir` and returning
  `sf`/`terra` objects.
- Roxygen tags and generated `.Rd` files (aside from updating them
  automatically via
  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)).
- `pkgdown` YAML structure (`_pkgdown.yml`), bootstrap 5 theme, navbars.
- Existing network-heavy downloads inside tests (they are correctly
  conditionally skipped via helper functions).
- `purl = FALSE` / `eval = FALSE` in `vignettes/getting-started.Rmd`
  chunks (except the setup chunk, which is correctly excluded from this
  behavior to preserve the package load during `R CMD check`).
