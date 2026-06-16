# Audit Report for fireR

## Must fix
- `get_fod` uses `httr2::req_perform(req, path = zip_file)` but misses progress bar mapping for verbose output and retry logic for transient errors.
- Network-heavy code chunks in vignettes that are not meant to be evaluated during checks may be inappropriately missing `eval = FALSE, purl = FALSE`, although some smaller datasets may be evaluated. In `vignettes/getting-started.Rmd`, chunks like `all-fires` already use this properly. The `gallery-` chunks download ~10MB, which is safe, so they do not need this fix.

## Safe improvements
- Adding `req_progress` and `req_retry` to the `httr2` request chain in `get_fod()`.

## Possible features, but defer unless needed
- Add caching configuration options.
- Add dry-run/list-available-years helper.

## Do not touch
- `_pkgdown.yml`, structure, logo, theme.
- Exported function names, defaults.
