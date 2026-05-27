test_that("get_mtbs() rejects invalid arguments", {
  expect_error(get_mtbs(dataset = "bad"), "bad")

  expect_error(get_mtbs(directory = 123), "character string")
  expect_error(get_mtbs(directory = c("a", "b")), "character string")
  expect_error(get_mtbs(directory = NA_character_), "character string")

  expect_error(get_mtbs(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_mtbs(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
  expect_error(get_mtbs(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_mtbs(timeout = "3600"), "positive number")
  expect_error(get_mtbs(timeout = -1), "positive number")
  expect_error(get_mtbs(timeout = NA_real_), "positive number")
  expect_error(get_mtbs(timeout = c(10, 20)), "positive number")

  expect_error(get_mtbs(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_mtbs(verbose = NA), "TRUE.*FALSE")
})

test_that("read_mtbs() input validation works", {

  # invalid dataset
  expect_error(read_mtbs(dataset = "bad"), "bad")

  # geometry must be logical
  expect_error(read_mtbs(geometry = "yes"), "TRUE.*FALSE")

  # invalid type
  expect_error(read_mtbs(type = "BadType"), "Unknown.*type")
  expect_error(read_mtbs(type = 123), "non-empty character")
  expect_error(read_mtbs(type = NA_character_), "NA")
  expect_error(read_mtbs(type = character(0)), "non-empty character")
  expect_error(read_mtbs(type = list("Wildfire")), "non-empty character")

  # invalid years
  expect_error(read_mtbs(years = "bad"), "non-empty")
  expect_error(read_mtbs(years = NA_integer_), "NA")
  expect_error(read_mtbs(years = integer(0)), "non-empty")

  # invalid cache
  expect_error(read_mtbs(cache = 123), "logical or character")
  expect_error(read_mtbs(cache = c("a", "b")), "logical or character")

  # invalid output
  expect_error(read_mtbs(output = "bad"), "bad")

  # invalid verbose
  expect_error(read_mtbs(verbose = "yes"), "TRUE.*FALSE")
  expect_error(read_mtbs(verbose = NA), "TRUE.*FALSE")
})

shared_cache <- file.path(tempdir(), "mtbs_shared_test_cache")

test_that("read_mtbs() returns the right class", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(directory = cache_dir, verbose = FALSE)

  # sf (default)
  result_sf <- read_mtbs(years = 2020, output = "sf", cache = cache_dir, verbose = FALSE)
  expect_s3_class(result_sf, "sf")

  # terra SpatVector
  result_vect <- read_mtbs(years = 2020, output = "vect", cache = cache_dir, verbose = FALSE)
  expect_s4_class(result_vect, "SpatVector")

  # data.frame when geometry = FALSE
  result_df <- read_mtbs(years = 2020, geometry = FALSE, cache = cache_dir, verbose = FALSE)
  expect_s3_class(result_df, "data.frame")
  expect_false("geometry" %in% names(result_df))
})

test_that("year range filtering keeps correct rows", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = 2018:2019, output = "sf", cache = cache_dir, verbose = FALSE)

  dates <- as.Date(fires[["Ig_Date"]])
  yrs   <- as.integer(format(dates, "%Y"))
  expect_true(all(yrs %in% 2018:2019, na.rm = TRUE))
})

test_that("specific year vector filtering keeps correct rows", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = c(2018, 2020), output = "sf", cache = cache_dir, verbose = FALSE)

  dates <- as.Date(fires[["Ig_Date"]])
  yrs   <- as.integer(format(dates, "%Y"))
  expect_true(all(yrs %in% c(2018, 2020), na.rm = TRUE))
})

test_that("single year is treated as exact match", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = 2005, output = "sf", cache = cache_dir, verbose = FALSE)
  dates <- as.Date(fires[["Ig_Date"]])
  yrs   <- as.integer(format(dates, "%Y"))
  expect_true(all(yrs == 2005, na.rm = TRUE))
})

test_that("type filtering keeps correct rows", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = 2020, type = "Wildfire", output = "sf", cache = cache_dir, verbose = FALSE)
  expect_true(all(fires[["Incid_Type"]] == "Wildfire", na.rm = TRUE))
})

test_that("read_mtbs() can read occurrence data", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- shared_cache
  get_mtbs(dataset = "occurrence", directory = cache_dir, verbose = FALSE)

  # Check that it returns a spatial object
  result_sf <- read_mtbs(dataset = "occurrence", years = 2020, output = "sf", cache = cache_dir, verbose = FALSE)
  expect_s3_class(result_sf, "sf")

  # Type filtering for occurrence
  fires_wildfire <- read_mtbs(dataset = "occurrence", years = 2020, type = "Wildfire", output = "sf", cache = cache_dir, verbose = FALSE)
  expect_true(all(fires_wildfire[["Incid_Type"]] == "Wildfire", na.rm = TRUE))
})

test_that("get_mtbs() downloads and returns ZIP path", {
  skip_if_usgs_unreachable()
  skip_on_cran()

  cache_dir <- file.path(tempdir(), "mtbs_download_only")
  zip_path <- get_mtbs(directory = cache_dir, verbose = FALSE)
  expect_type(zip_path, "character")
  expect_true(file.exists(zip_path))
  expect_true(grepl("mtbs_perimeter_data\\.zip$", zip_path))
  expect_false(dir.exists(file.path(cache_dir, "mtbs_perimeter_data")))
})

test_that("read_mtbs() does not download and errors when ZIP is missing", {
  cache_dir <- file.path(tempdir(), "mtbs_cache_missing_zip")
  expect_error(
    read_mtbs(cache = cache_dir, verbose = FALSE),
    "No MTBS ZIP file found"
  )
})
