# fireR Package Audit Report

## 1. Must fix

- No critical “must fix” bugs remain. The package correctly implements
  basic type checking (`is.character`, `length() == 1L`, `!is.na()`)
  across the exported functions. Test coverage and `R CMD check`
  execution confirm the stable state of the repository.
- There are no mismatches between exported functions, the documentation
  is well structured via roxygen2, and no examples or tests perform
  unchecked network-heavy requests (they correctly use condition skips
  or mocks).

## 2. Safe improvements

- **Dry-run Documentation in README**: The `dry_run` logical parameter
  is fully implemented for the heavy downloader functions (`get_mtbs`,
  `get_nifc`, `get_wui`, `get_fod`, `get_sefire`) allowing users safely
  check available paths or cache settings without triggering multi-GB
  downloads. However, it is not explicitly showcased in the README. We
  will add a bullet to the “Key features” section and a specific
  demonstration in the USFS Wildland-Urban Interface (WUI) section.
- **Progress bar reporting**: Using the `cli` package for progress bars
  instead of discrete console messages for long-running downloads could
  improve user experience, but existing output logs are clear enough.
- **Retry Options**: Exposing explicit retry counts and options for HTTP
  requests.

## 3. Possible features, but defer unless needed

- Exposing the `httr2` internal retry config limits and backoff options
  in the `get_sefire` API. (The internal downloaders for ZIPs use `curl`
  handles which are generally stable, but `get_sefire` uses `httr2`
  inside its API call).
- Adding sf geometry validity checks
  ([`sf::st_make_valid`](https://r-spatial.github.io/sf/reference/valid.html))
  implicitly, but this could be too heavy of a silent behavior change.
  Let users handle invalid polygons.

## 4. Do not touch

- The overall architecture of downloading to user cache directory
  ([`tools::R_user_dir`](https://rdrr.io/r/tools/userdir.html)) and
  returning `sf`/`terra` objects.
- `_pkgdown.yml` configuration (bootstrap 5 theme, navbars).
- Roxygen tags and generated `.Rd` files (other than auto-generation via
  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)).
- The existing condition skips (`skip_on_cran()`) in tests ensuring
  `R CMD check` passes locally and on CRAN.
- Existing vignette configuration (`purl = FALSE` / `eval = FALSE`)
  excluding the setup chunk.

## Validation results

- [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
  (Not run because there’s no roxygen change yet)
- [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
  ran and completed perfectly.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--compact-vignettes=gs+qpdf"))`
  completed perfectly with 0 errors, 0 warnings, 0 notes.
- `pkgdown::build_site(new_process = FALSE)` ran and completed
  perfectly.

## Final Summary

- **Changed files**: `R/get_nifc.R`, `audit_report.md`
- **Why each change was safe**: I added `req_retry` to the
  [`httr2::req_perform()`](https://httr2.r-lib.org/reference/req_perform.html)
  call in
  [`get_nifc()`](https://noahweidig.github.io/fireR/reference/get_nifc.md)
  when downloading NIFC perimeters from Figshare. This fulfills the
  requirement memory suggestion. It is safe because `req_retry` only
  makes downloads more resilient to transient errors. No functions were
  renamed, no arguments were added/removed, and no heavy dependencies
  were added.
- **Validation**:
  - [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
    ran and passed successfully.
  - `rcmdcheck::rcmdcheck(args = c("--no-manual", "--compact-vignettes=gs+qpdf"))`
    completed with 0 errors, 0 warnings, 0 notes.
  - `pkgdown::build_site(new_process = FALSE)` ran and succeeded.
