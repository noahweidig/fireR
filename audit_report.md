# fireR Package Audit Report

## 1. Must fix

- No critical “must fix” bugs remain. Explicit validation
  (`is.character`, `length() == 1L`, `!is.na()`, etc.) for parameters
  (`directory`, `overwrite`, `verbose`, `state`, `timeout`) are
  correctly implemented across all exported functions, ensuring they
  fail fast with clear errors. Test coverage and continuous integration
  checks already provide strong assurance of stability.

## 2. Safe improvements

- **Argument validation**: The strict type validation for the `type`
  argument in
  [`read_mtbs()`](https://noahweidig.github.io/fireR/reference/read_mtbs.md)
  (ensuring it is `is.character`, has length \> 0, and
  `!any(is.na(type))`) is actually already present in the codebase.
- **Documentation clarifications**: Update `README.md` to properly
  document the `cache` arguments. The original examples for
  `read_mtbs(cache = TRUE)` and `read_nifc(cache = TRUE)` misleadingly
  implied that these functions handled the initial download. The updated
  documentation correctly demonstrates running
  `get_mtbs(directory = tools::R_user_dir("fireR", "cache"))` before
  attempting to load data from that cache.

## 3. Possible features, but defer unless needed

- Dry-run capability or a `list-available-years` helper to check
  available datasets without downloading.
- Progress bar reporting instead of discrete console messages for
  long-running downloads (e.g. via the `cli` package).
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
