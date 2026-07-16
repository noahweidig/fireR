# Audit Report: `fireR` Package

## 1. Must fix
- None found. The package is highly robust, explicitly uses `dry_run` arguments correctly, has consistent defaults, and passes all tests successfully.

## 2. Safe improvements
- **Warnings for large files:** The `get_nifc()` function and the NIFC section in the `README.md` are missing the warning blocks for large files, which exist consistently for `get_mtbs()`, `get_sefire()`, `get_wui()`, and `get_fod()`. Adding this makes the behavior and documentation consistent and explicitly alerts users about slow network operations, which satisfies the prompt's request to identify "functions that download huge files without clear warnings".

## 3. Possible features, but defer unless needed
- **Consolidate default output format:** Ecoregion loaders default to `output = "sf"`, but the rest default to `output = "vect"`. Unifying this to `"sf"` would be a breaking change, so it must be deferred.

## 4. Do not touch
- **Package Architecture & Namespace:** Do not touch `NAMESPACE` or the package structure.
- **pkgdown config:** `_pkgdown.yml` is correctly formatted. Do not touch.
- **Branding:** Do not touch branding, logo, or `.Rd` files (update via `roxygen2`).
