test_that("get_nifc() rejects invalid arguments", {
  expect_error(get_nifc(directory = 123), "character string")
  expect_error(get_nifc(directory = c("a", "b")), "character string")
  expect_error(get_nifc(directory = NA_character_), "character string")

  expect_error(get_nifc(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_nifc(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
  expect_error(get_nifc(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_nifc(timeout = "3600"), "positive number")
  expect_error(get_nifc(timeout = -1), "positive number")
  expect_error(get_nifc(timeout = NA_real_), "positive number")
  expect_error(get_nifc(timeout = c(10, 20)), "positive number")

  expect_error(get_nifc(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_nifc(verbose = NA), "TRUE.*FALSE")

  expect_error(get_nifc(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_nifc(dry_run = NA), "TRUE.*FALSE")
})

test_that("get_nifc() respects dry_run", {
  tmp <- file.path(tempdir(), "nifc_dryrun_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  res <- get_nifc(directory = tmp, dry_run = TRUE, verbose = FALSE)
  expect_type(res, "character")
  expect_true(grepl("nifc_perimeters\\.zip$", res))
  expect_false(file.exists(res))
})

test_that("get_fod() rejects invalid arguments", {
  expect_error(get_fod(directory = 123), "character string")
  expect_error(get_fod(directory = c("a", "b")), "character string")
  expect_error(get_fod(directory = NA_character_), "character string")

  expect_error(get_fod(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_fod(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
  expect_error(get_fod(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_fod(timeout = "3600"), "positive number")
  expect_error(get_fod(timeout = -1), "positive number")
  expect_error(get_fod(timeout = NA_real_), "positive number")
  expect_error(get_fod(timeout = c(10, 20)), "positive number")

  expect_error(get_fod(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_fod(verbose = NA), "TRUE.*FALSE")

  expect_error(get_fod(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_fod(dry_run = NA), "TRUE.*FALSE")
})

test_that("get_fod() respects dry_run", {
  tmp <- file.path(tempdir(), "fod_dryrun_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  res <- get_fod(directory = tmp, dry_run = TRUE, verbose = FALSE)
  expect_type(res, "character")
  expect_true(grepl("RDS-2013-0009\\.6_Data_Format3_GPKG\\.zip$", res))
  expect_false(file.exists(res))
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
  expect_error(read_nifc(years = 2020.5),      "non-empty integer")
})

test_that("read_nifc() errors when ZIP is missing", {
  cache_dir <- file.path(tempdir(), "nifc_missing_zip")
  expect_error(
    read_nifc(cache = cache_dir, verbose = FALSE),
    "No NIFC ZIP file found"
  )
})

test_that("read_nifc() rejects invalid cache argument", {
  expect_error(read_nifc(cache = 123), "logical or character")
  expect_error(read_nifc(cache = c("a", "b")), "logical or character")
  expect_error(read_nifc(cache = NA), "logical or character")
  expect_error(read_nifc(cache = NA_character_), "logical or character")
})

test_that("read_nifc() rejects invalid output argument", {
  expect_error(read_nifc(output = "bad"), "bad")
})

test_that("read_nifc() rejects invalid verbose argument", {
  expect_error(read_nifc(verbose = "yes"), "TRUE.*FALSE")
  expect_error(read_nifc(verbose = NA), "TRUE.*FALSE")
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
  skip_if_invalid_nifc_archive(shared_nifc_cache)

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
  skip_if_invalid_nifc_archive(shared_nifc_cache)

  perims <- read_nifc(years = 2018:2019, output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_true(all(perims[["FireYear"]] %in% 2018:2019, na.rm = TRUE))
})

test_that("read_nifc() single year is treated as exact match", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)
  skip_if_invalid_nifc_archive(shared_nifc_cache)

  perims <- read_nifc(years = 2005, output = "sf", cache = shared_nifc_cache, verbose = FALSE)
  expect_true(all(perims[["FireYear"]] == 2005, na.rm = TRUE))
})

test_that("read_nifc() specific year vector filtering keeps correct rows", {
  skip_if_nifc_unreachable()
  skip_on_cran()
  get_nifc(directory = shared_nifc_cache, verbose = FALSE)
  skip_if_invalid_nifc_archive(shared_nifc_cache)

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
  expect_error(read_fod(years = 2020.5),      "non-empty integer")
})

test_that("read_fod() errors when ZIP is missing", {
  cache_dir <- file.path(tempdir(), "fod_missing_zip")
  expect_error(
    read_fod(cache = cache_dir, verbose = FALSE),
    "No FOD ZIP file found"
  )
})

test_that("read_fod() rejects invalid cache argument", {
  expect_error(read_fod(cache = 123), "logical or character")
  expect_error(read_fod(cache = c("a", "b")), "logical or character")
  expect_error(read_fod(cache = NA), "logical or character")
  expect_error(read_fod(cache = NA_character_), "logical or character")
})

test_that("read_fod() rejects invalid output argument", {
  expect_error(read_fod(output = "bad"), "bad")
})

test_that("read_fod() rejects invalid verbose argument", {
  expect_error(read_fod(verbose = "yes"), "TRUE.*FALSE")
  expect_error(read_fod(verbose = NA), "TRUE.*FALSE")
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
