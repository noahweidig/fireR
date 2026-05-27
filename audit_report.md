# fireR Package Audit Report

## 1. Must fix
- No critical "must fix" bugs remain. Explicit validation (`is.character`, `length() == 1L`, `!is.na()`, etc.) for parameters (`directory`, `overwrite`, `verbose`, `state`, `timeout`) are correctly implemented across all exported functions, ensuring they fail fast with clear errors. Test coverage and continuous integration checks already provide strong assurance of stability.

## 2. Safe improvements
- **Argument validation**: Add stricter validation for the `type` argument in `read_mtbs()` (ensure it is `is.character`, has length > 0, and `!any(is.na(type))`) before validating against valid types (`"Wildfire"`, `"Prescribed Fire"`, `"Unknown"`, `"Wildland Fire Use"`).
- **Test coverage**: Add `testthat` coverage for the strict `type` validation in `read_mtbs()` to match the stricter argument validation.

## 3. Possible features, but defer unless needed
- Dry-run capability or a `list-available-years` helper to check available datasets without downloading.
- Progress bar reporting instead of discrete console messages for long-running downloads (e.g. via the `cli` package).
- Exposing explicit retry counts and options for HTTP requests.

## 4. Do not touch
- The overall architecture of downloading to `cache_dir` and returning `sf`/`terra` objects.
- Roxygen tags and generated `.Rd` files (aside from updating them automatically via `devtools::document()`).
- `pkgdown` YAML structure (`_pkgdown.yml`), bootstrap 5 theme, navbars.
- Existing network-heavy downloads inside tests (they are correctly conditionally skipped via helper functions).
- `purl = FALSE` / `eval = FALSE` in `vignettes/getting-started.Rmd` chunks (except the setup chunk, which is correctly excluded from this behavior to preserve the package load during `R CMD check`).
