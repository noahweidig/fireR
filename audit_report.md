## Audit Report

### Must Fix
* None found. The package passes `R CMD check` without warnings or errors. No broken examples or pkgdown build failures detected.

### Safe Improvements
* **Vignette Chunk Headers:** Rmarkdown chunk headers in `getting-started.Rmd` use `purl = FALSE` when loading the package (`library(fireR)`) in the setup chunk. This will cause the `library()` call to be excluded from the tangled `.R` script during tests, which can break subsequent chunks if `eval = TRUE` later. Memory instructions state: "NEVER add `purl = FALSE` or `eval = FALSE` to setup chunks that load the package".

### Possible Features (Defer unless needed)
* Adding argument validations or a dry-run helper to list available years.
* Improving cache messaging or showing size warnings on more functions.

### Do Not Touch
* The `_pkgdown.yml` file, overall package architecture, downloaded datasets logic, and the `tests` logic that skip downloads when endpoints are unreachable (which are currently working as intended).
