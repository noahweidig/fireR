# Audit Report: `fireR` Package

## 1. Must fix
- None found. The package is stable, passes R CMD check, correctly manages namespaces, properly handles caching logic, and has a strong test suite validating its exported functions.

## 2. Safe improvements
- **Documentation:** The `README.md` provides an explicit argument table for `read_mtbs()` but lacks similar tables for the other main reader functions (`read_nifc()` and `read_fod()`). Adding these tables makes the documentation more consistent and easier to read without having to look at `?read_nifc` and `?read_fod`.

## 3. Possible features, but defer unless needed
- **Inconsistent output defaults:** The `read_*` functions (`read_mtbs`, `read_nifc`, `read_fod`) default to `output = "vect"`, whereas the `get_eco` functions default to `output = "sf"`. Unifying the default across all functions to `"sf"` might make the package more coherent, but would be a backward-incompatible breaking change. Defer unless explicitly requested.

## 4. Do not touch
- **Package Architecture & Namespace:** The current `roxygen2`-generated `NAMESPACE` and file structure are clean and functional. Do not manually edit.
- **pkgdown Configuration:** The `_pkgdown.yml` file correctly lists all exported functions in logical groups, uses Bootstrap 5, and includes the necessary GitHub Pages workflow components.
- **Branding:** The logo and custom theming must be strictly preserved.
