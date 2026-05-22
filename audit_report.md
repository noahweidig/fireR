# fireR Package Audit Report

## 1. Must fix
- Explicit input validation is missing for common arguments (`directory`, `overwrite`, `timeout`, `verbose`, `state`) across all `get_*` and `read_*` exported functions. The memory instructions specifically require strict, explicit input validation for all parameters to fail fast with clear errors.

## 2. Safe improvements
- Add strict, explicit validation (`is.character`, `length() == 1L`, `!is.na()`, etc.) for `directory`, `overwrite`, `timeout`, and `verbose` in `get_mtbs()`, `get_sefire()`, `get_wui()`, `get_nifc()`, and `get_fod()`.
- Add strict explicit validation for `verbose` in `read_mtbs()`, `read_nifc()`, and `read_fod()`.
- Add explicit validation for `verbose` in `get_nal1eco()`, `get_nal2eco()`, and `get_nal3eco()`.
- Add explicit validation for `state` and `verbose` in `get_usl3eco()` and `get_usl4eco()`.
- Add test coverage (`testthat`) asserting that invalid inputs for these arguments are appropriately caught and rejected.

## 3. Possible features, but defer unless needed
- Dry-run capability to list available datasets without downloading.
- Progress bar reporting instead of discrete messages.
- Exposing retry counts for HTTP requests.

## 4. Do not touch
- The overall architecture of downloading to `cache_dir` and returning `sf`/`terra` objects.
- Roxygen tags and generated Rd files (aside from updating them automatically via `devtools::document()`).
- `pkgdown` YAML structure, bootstrap 5 theme, navbars.
- Existing network-heavy downloads inside tests (they are correctly conditionally skipped via helper functions).
- `purl = FALSE` / `eval = FALSE` in `vignettes/getting-started.Rmd` (except the setup chunk, which is correctly excluded from this behavior).
