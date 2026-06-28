# fireR Package Audit Report

## 1. Must fix
- No critical "must fix" bugs remain. The package correctly implements strict basic type checking (`is.character`, `length() == 1L`, `!is.na()`) and modulus division (`years %% 1 != 0`) for integers across the exported functions.
- `httr2::req_retry` is already present where appropriate, and `dry_run` safely works to prevent multi-GB downloads.

## 2. Safe improvements
- Added `suppressWarnings()` around test calls that trigger expected "large download" warnings from `cli::cli_warn()`. This prevents the test output from being polluted with expected warnings during normal CRAN testing. (Note: These were already implemented and confirmed correct.)
- Fixed documentation dataset name consistency for 'Burned Area Rasters' in R/get_sefire.R.

## 3. Possible features, but defer unless needed
- Exposing the `httr2` internal retry config limits and backoff options in the API.
- Adding sf geometry validity checks (`sf::st_make_valid`) implicitly, but this could be too heavy of a silent behavior change. Let users handle invalid polygons.

## 4. Do not touch
- The overall architecture of downloading to user cache directory (`tools::R_user_dir`) and returning `sf`/`terra` objects.
- `_pkgdown.yml` configuration (bootstrap 5 theme, navbars).
- Roxygen tags and generated `.Rd` files (other than auto-generation via `devtools::document()`).
- The existing condition skips (`skip_on_cran()`) in tests ensuring `R CMD check` passes locally and on CRAN.
- Existing vignette configuration (`purl = FALSE` / `eval = FALSE`) excluding the setup chunk.
