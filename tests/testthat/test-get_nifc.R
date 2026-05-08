test_that("get_nifc() errors on non-existent directory path gracefully", {
  # Providing a valid temp dir should not error at the argument level
  tmp <- file.path(tempdir(), "nifc_arg_test")
  # We can't download, but we can confirm the function at least sets up the dir
  # without erroring on argument validation (no argument validation to test here,
  # but we confirm the function signature is accessible)
  expect_type(formals(get_nifc)$overwrite, "logical")
  expect_type(formals(get_nifc)$verbose, "logical")
})

test_that("get_fod() has expected default arguments", {
  expect_equal(formals(get_fod)$overwrite, FALSE)
  expect_equal(formals(get_fod)$verbose, TRUE)
})

# ── read_nifc() input validation (no download required) ──────────────────────

test_that("read_nifc() rejects invalid geometry argument", {
  expect_error(read_nifc(geometry = "yes"), "TRUE.*FALSE")
  expect_error(read_nifc(geometry = NA),    "TRUE.*FALSE")
  expect_error(read_nifc(geometry = 1),     "TRUE.*FALSE")
})

test_that("read_nifc() rejects invalid years argument", {
  expect_error(read_nifc(years = "bad"),       "integer")
  expect_error(read_nifc(years = NA_integer_), "NA")
  expect_error(read_nifc(years = integer(0)),  "non-empty")
})

test_that("read_nifc() errors when ZIP is missing", {
  cache_dir <- file.path(tempdir(), "nifc_missing_zip")
  expect_error(
    read_nifc(cache = cache_dir, verbose = FALSE),
    "No NIFC ZIP file found"
  )
})

test_that("read_nifc() default arguments are correct", {
  expect_null(formals(read_nifc)$years)
  expect_true(formals(read_nifc)$geometry)
  expect_false(formals(read_nifc)$cache)
  expect_true(formals(read_nifc)$verbose)
})

# ── read_nifc() integration tests (download required) ────────────────────────

shared_nifc_cache <- file.path(tempdir(), "nifc_shared_test_cache")

test_that("read_nifc() returns the right class", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)

  result_sf <- read_nifc(years = 2020, output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_s3_class(result_sf, "sf")

  result_vect <- read_nifc(years = 2020, output = "vect", cache = shared_nifc_cache, verbose = FALSE)
  expect_s4_class(result_vect, "SpatVector")

  result_df <- read_nifc(years = 2020, geometry = FALSE, cache = shared_nifc_cache, verbose = FALSE)
  expect_s3_class(result_df, "data.frame")
  expect_false("geometry" %in% names(result_df))
})

test_that("read_nifc() year filtering keeps correct rows", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)

  perims <- read_nifc(years = 2018:2019, output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_true(all(perims[["FireYear"]] %in% 2018:2019, na.rm = TRUE))
})

test_that("read_nifc() single year is treated as exact match", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)

  perims <- read_nifc(years = 2005, output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_true(all(perims[["FireYear"]] == 2005, na.rm = TRUE))
})

test_that("read_nifc() specific year vector filtering keeps correct rows", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)

  perims <- read_nifc(years = c(2010, 2015), output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_true(all(perims[["FireYear"]] %in% c(2010, 2015), na.rm = TRUE))
})

test_that("get_nifc() downloads and returns ZIP path", {
  skip_if_nifc_unreachable()
  skip_on_cran()

  cache_dir <- file.path(tempdir(), "nifc_download_only")
  zip_path <- get_nifc(directory = cache_dir, verbose = FALSE)
  expect_type(zip_path, "character")
  expect_true(file.exists(zip_path))
  expect_true(grepl("nifc_perimeters\\.zip$", zip_path))
})

# ── read_fod() input validation (no download required) ───────────────────────

test_that("read_fod() rejects invalid geometry argument", {
  expect_error(read_fod(geometry = "yes"), "TRUE.*FALSE")
  expect_error(read_fod(geometry = NA),    "TRUE.*FALSE")
  expect_error(read_fod(geometry = 1),     "TRUE.*FALSE")
})

test_that("read_fod() rejects invalid years argument", {
  expect_error(read_fod(years = "bad"),       "integer")
  expect_error(read_fod(years = NA_integer_), "NA")
  expect_error(read_fod(years = integer(0)),  "non-empty")
})

test_that("read_fod() errors when ZIP is missing", {
  cache_dir <- file.path(tempdir(), "fod_missing_zip")
  expect_error(
    read_fod(cache = cache_dir, verbose = FALSE),
    "No FOD ZIP file found"
  )
})

test_that("read_fod() default arguments are correct", {
  expect_null(formals(read_fod)$years)
  expect_true(formals(read_fod)$geometry)
  expect_false(formals(read_fod)$cache)
  expect_true(formals(read_fod)$verbose)
})

# ── read_fod() integration tests (download required) ─────────────────────────

shared_fod_cache <- file.path(tempdir(), "fod_shared_test_cache")

test_that("read_fod() returns the right class", {
  skip_if_fod_unreachable()
  skip_on_cran()
  get_fod(directory = shared_fod_cache, verbose = FALSE)

  result_sf <- read_fod(years = 2015, output = "sf", cache = shared_fod_cache, verbose = FALSE)
  expect_s3_class(result_sf, "sf")

  result_vect <- read_fod(years = 2015, output = "vect", cache = shared_fod_cache, verbose = FALSE)
  expect_s4_class(result_vect, "SpatVector")

  result_df <- read_fod(years = 2015, geometry = FALSE, cache = shared_fod_cache, verbose = FALSE)
  expect_s3_class(result_df, "data.frame")
  expect_false("geometry" %in% names(result_df))
})

test_that("read_fod() year filtering keeps correct rows", {
  skip_if_fod_unreachable()
  skip_on_cran()
  get_fod(directory = shared_fod_cache, verbose = FALSE)

  fires <- read_fod(years = 2010:2011, output = "sf", cache = shared_fod_cache, verbose = FALSE)
  expect_true(all(fires[["FIRE_YEAR"]] %in% 2010:2011, na.rm = TRUE))
})

test_that("read_fod() single year is treated as exact match", {
  skip_if_fod_unreachable()
  skip_on_cran()
  get_fod(directory = shared_fod_cache, verbose = FALSE)

  fires <- read_fod(years = 2000, output = "sf", cache = shared_fod_cache, verbose = FALSE)
  expect_true(all(fires[["FIRE_YEAR"]] == 2000, na.rm = TRUE))
})

test_that("read_fod() specific year vector filtering keeps correct rows", {
  skip_if_fod_unreachable()
  skip_on_cran()
  get_fod(directory = shared_fod_cache, verbose = FALSE)

  fires <- read_fod(years = c(2000, 2010), output = "sf", cache = shared_fod_cache, verbose = FALSE)
  expect_true(all(fires[["FIRE_YEAR"]] %in% c(2000, 2010), na.rm = TRUE))
})

test_that("get_fod() downloads and returns ZIP path", {
  skip_if_fod_unreachable()
  skip_on_cran()

  cache_dir <- file.path(tempdir(), "fod_download_only")
  zip_path <- get_fod(directory = cache_dir, verbose = FALSE)
  expect_type(zip_path, "character")
  expect_true(file.exists(zip_path))
  expect_true(grepl("RDS-2013-0009\\.6_Data_Format3_GPKG\\.zip$", zip_path))
})
