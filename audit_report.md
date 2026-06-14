# Audit Report for fireR

## "Must fix"
- None found; the repository passes all tests, `R CMD check`, and `pkgdown` builds perfectly out-of-the-box. There are no CRAN-breaking bugs or severe documentation mismatches.

## "Safe improvements"
1. **Network Resilience in `get_fod`:** The `httr2::req_perform()` call for downloading the USFS FOD data in `R/get_nifc.R` lacks retry logic and progress reporting. Adding `httr2::req_retry(max_tries = 3)` makes the network call robust against transient failures. Adding `httr2::req_progress()` conditionally based on the `verbose` flag ensures a better user experience without breaking automated logs.

## "Possible features, but defer unless needed"
- A helper function to list available MTBS years or SE FireMap datasets could be nice, but since `get_mtbs` and `get_sefire` already have `dry_run` and clear documentation, we can defer adding new exported functions to maintain strict backwards compatibility.

## "Do not touch"
- Package architecture (which relies on `curl` and `httr2` selectively).
- `_pkgdown.yml` configuration.
- Tests (since they currently skip network-heavy downloads gracefully or use temp dirs correctly).
