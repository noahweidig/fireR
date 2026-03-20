test_that("read_mtbs() input validation works", {

  # years length > 2
  expect_error(read_mtbs(years = c(2000, 2010, 2020)), "length 1 or 2")

  # geometry must be logical
  expect_error(read_mtbs(geometry = "yes"), "TRUE.*FALSE")

  # invalid type
  expect_error(read_mtbs(type = "BadType"), "Unknown.*type")
})

test_that("read_mtbs() returns the right class", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- file.path(tempdir(), "mtbs_cache_classes")
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

test_that("year filtering keeps correct rows", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- file.path(tempdir(), "mtbs_cache_year_range")
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = c(2018, 2019), output = "sf", cache = cache_dir, verbose = FALSE)

  dates <- as.Date(fires[["Ig_Date"]])
  yrs   <- as.integer(format(dates, "%Y"))
  expect_true(all(yrs >= 2018 & yrs <= 2019, na.rm = TRUE))
})

test_that("single year is treated as exact match", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- file.path(tempdir(), "mtbs_cache_single_year")
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = 2005, output = "sf", cache = cache_dir, verbose = FALSE)
  dates <- as.Date(fires[["Ig_Date"]])
  yrs   <- as.integer(format(dates, "%Y"))
  expect_true(all(yrs == 2005, na.rm = TRUE))
})

test_that("type filtering keeps correct rows", {
  skip_if_usgs_unreachable()
  skip_on_cran()
  cache_dir <- file.path(tempdir(), "mtbs_cache_type")
  get_mtbs(directory = cache_dir, verbose = FALSE)

  fires <- read_mtbs(years = 2020, type = "Wildfire", output = "sf", cache = cache_dir, verbose = FALSE)
  expect_true(all(fires[["Incid_Type"]] == "Wildfire", na.rm = TRUE))
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
