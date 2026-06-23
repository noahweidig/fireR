# fireR Package Audit Report

## 1. Must fix

- No critical “must fix” bugs remain. The package correctly implements
  strict basic type checking (`is.character`, `length() == 1L`,
  `!is.na()`) and modulus division (`years %% 1 != 0`) for integers
  across the exported functions.
- Test coverage and `R CMD check` execution confirm the stable state of
  the repository.
- There are no severe mismatches between exported functions, the
  documentation is well structured via roxygen2, and no examples or
  tests perform unchecked network-heavy requests (they correctly use
  condition skips or mocks).
- [`httr2::req_retry`](https://httr2.r-lib.org/reference/req_retry.html)
  is already present where appropriate, and `dry_run` safely works to
  prevent multi-GB downloads.

## 2. Safe improvements

- **Documentation Mismatch Fixes**:
  - `README.md` shows `read_mtbs(years = 2010:2023, output = "sf")` as
    its year range example, but `R/get_mtbs.R` roxygen comments document
    `\code{2010:2020}` and show `2018:2023` in the examples. Updating
    the `R/get_mtbs.R` examples to precisely match the README is a very
    safe improvement.

## 3. Possible features, but defer unless needed

- Exposing the `httr2` internal retry config limits and backoff options
  in the API.
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
  ran correctly and updated the `man/` entries.
- [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
  ran and completed perfectly.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--compact-vignettes=gs+qpdf"))`
  completed perfectly with 0 errors, 0 warnings, 0 notes.
- `pkgdown::build_site(new_process = FALSE)` ran and completed
  perfectly.

## Final Summary

- **Changed files**: `audit_report.md`, `R/get_mtbs.R`
- **Why each change was safe**: Updating the roxygen comments in
  `R/get_mtbs.R` to accurately reflect the `README.md` ranges
  (`2010:2023`) resolves a documentation mismatch without affecting
  functionality.
- **Validation**: All tests and CRAN checks passed successfully.
