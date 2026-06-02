# fireR Package Audit Report

## 1. Must fix

- No critical “must fix” bugs remain. The package correctly implements
  basic type checking (`is.character`, `length() == 1L`, `!is.na()`)
  across the exported functions. Test coverage and `R CMD check`
  execution confirm the stable state of the repository.

## 2. Safe improvements

- **Strict Integer Validation Tests**: While the years arguments (in
  `read_mtbs`, `read_nifc`, `read_fod`, `get_sefire`) use `is.numeric`
  and correctly check `years %% 1 != 0` to fail fast on non-integer
  numeric vectors, there are currently no test blocks verifying this
  behavior. Adding explicit `expect_error` checks for decimal numeric
  inputs (e.g., `2020.5`) will fully cover this safe parameter
  validation.
- **Documentation clarifications**: The examples in the README
  adequately explain the caching behavior, avoiding implicit download
  assumptions. No major changes are required here.

## 3. Possible features, but defer unless needed

- **Dry-run capability**: A `dry_run` capability or
  `list-available-years` helper could be added to check available
  datasets without triggering heavy downloads.
- **Progress bar reporting**: Using the `cli` package for progress bars
  instead of discrete console messages for long-running downloads could
  improve user experience.
- **Retry Options**: Exposing explicit retry counts and options for HTTP
  requests.

## 4. Do not touch

- The overall architecture of downloading to `cache_dir` and returning
  `sf`/`terra` objects.
- `_pkgdown.yml` configuration (bootstrap 5 theme, navbars).
- Roxygen tags and generated `.Rd` files (other than auto-generation via
  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)).
- The existing condition skips in tests ensuring `R CMD check` passes
  locally and on CRAN.
- Exiting vignette configuration (`purl = FALSE` / `eval = FALSE`)
  excluding the setup chunk.
