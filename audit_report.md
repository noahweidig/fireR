# fireR Package Audit Report

## 1. Must fix
- No critical "must fix" bugs remain. (Prior issues regarding missing explicit input validation for `directory`, `overwrite`, `timeout`, `verbose`, and `state` across `get_*` and `read_*` functions were addressed in a recent commit).

## 2. Safe improvements
- **README Documentation**: The `dataset` parameter is missing from the "`read_mtbs()` Arguments" table in the README. It needs to be documented so users know they can select between `"perimeters"` and `"occurrence"`.
- **Test Coverage**: The test suite validates `dataset` for `get_mtbs()`, but it misses a test for invalid `dataset` arguments inside `read_mtbs()`. An assertion should be added to `tests/testthat/test-get_mtbs.R`.

## 3. Possible features, but defer unless needed
- Dry-run capability to list available datasets without downloading.
- Progress bar reporting instead of discrete messages.
- Exposing retry counts for HTTP requests.
- Additional explicit `is.character` and `!any(is.na())` checks for `type` filtering in `read_mtbs()`.

## 4. Do not touch
- The overall architecture of downloading to `cache_dir` and returning `sf`/`terra` objects.
- Roxygen tags and generated Rd files (aside from updating them automatically via `devtools::document()`).
- `pkgdown` YAML structure, bootstrap 5 theme, navbars.
- Existing network-heavy downloads inside tests (they are correctly conditionally skipped via helper functions).
- `purl = FALSE` / `eval = FALSE` in `vignettes/getting-started.Rmd` (except the setup chunk, which is correctly excluded from this behavior).
