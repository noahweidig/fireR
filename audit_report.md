# fireR Package Audit Report

## 1. Must fix
- No critical "must fix" bugs remain. The package correctly implements basic type checking (`is.character`, `length() == 1L`, `!is.na()`) across the exported functions. Test coverage and `R CMD check` execution confirm the stable state of the repository.

## 2. Safe improvements
- **Dry-run capability**: A `dry_run` logical capability helper parameter is recommended for `get_mtbs`, `get_nifc`, `get_wui`, and `get_fod` to help users safely check available paths or cache settings without triggering heavy multi-GB downloads. *(Update: already correctly implemented in the codebase)*
- **Strict Integer Validation Tests**: The years arguments (in `read_mtbs`, `read_nifc`, `read_fod`, `get_sefire`) use `is.numeric` and correctly check `years %% 1 != 0` to fail fast on non-integer numeric vectors, and explicit `expect_error` checks for decimal numeric inputs (e.g., `2020.5`) are already implemented in the test suite. No new tests are needed for this behavior.
- **Cache Parameter NA Validation Tests**: The internal `cache` validation across the eco downloading tests (`test-get_eco.R`) already includes explicit tests for `cache = NA`.
- **Documentation clarifications**: The examples in the README adequately explain the caching behavior, avoiding implicit download assumptions. No major changes are required here.
- **Network Resilience Improvements**: Added conditional progress reporting `httr2::req_progress()` and automatic retry configuration `httr2::req_retry(req, max_tries = 3)` to the internal `httr2::req_perform()` calls (used for downloading FOD data) to better handle transient network failures.

## 3. Possible features, but defer unless needed
- **Progress bar reporting**: Using the `cli` package for progress bars instead of discrete console messages for long-running downloads could improve user experience. *(Update: `curl` native progress has been conditionally enforced during downloads, reducing the immediate need for a `cli`-based rewrite)*

## 4. Do not touch
- The overall architecture of downloading to `cache_dir` and returning `sf`/`terra` objects.
- `_pkgdown.yml` configuration (bootstrap 5 theme, navbars).
- Roxygen tags and generated `.Rd` files (other than auto-generation via `devtools::document()`).
- The existing condition skips in tests ensuring `R CMD check` passes locally and on CRAN.
- Existing vignette configuration (`purl = FALSE` / `eval = FALSE`) excluding the setup chunk.
