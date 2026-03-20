test_that("get_mtbs() input validation works", {

  # years length > 2
  expect_error(get_mtbs(years = c(2000, 2010, 2020)), "length 1 or 2")

  # return_spatial must be logical
  expect_error(get_mtbs(return_spatial = "yes"), "TRUE.*FALSE")
})

test_that("get_mtbs() returns the right class", {
  skip_if_offline()
  skip_on_cran()

  # sf (default)
  result_sf <- get_mtbs(years = 2020, output = "sf", verbose = FALSE)
  expect_s3_class(result_sf, "sf")

  # terra SpatVector
  result_vect <- get_mtbs(years = 2020, output = "vect", verbose = FALSE)
  expect_s4_class(result_vect, "SpatVector")

  # data.frame when return_spatial = FALSE
  result_df <- get_mtbs(years = 2020, return_spatial = FALSE, verbose = FALSE)
  expect_s3_class(result_df, "data.frame")
  expect_false("geometry" %in% names(result_df))
})

test_that("year filtering keeps correct rows", {
  skip_if_offline()
  skip_on_cran()

  fires <- get_mtbs(years = c(2018, 2019), output = "sf", verbose = FALSE)

  year_col <- intersect(c("Year", "YEAR", "year"), names(fires))
  if (length(year_col) > 0) {
    yrs <- as.integer(fires[[year_col[[1L]]]])
    expect_true(all(yrs >= 2018 & yrs <= 2019, na.rm = TRUE))
  } else {
    # Ig_Date path
    dates <- as.Date(
      as.character(fires[["Ig_Date"]]),
      tryFormats = c("%Y/%m/%d", "%Y-%m-%d")
    )
    yrs <- as.integer(format(dates, "%Y"))
    expect_true(all(yrs >= 2018 & yrs <= 2019, na.rm = TRUE))
  }
})

test_that("single year is treated as exact match", {
  skip_if_offline()
  skip_on_cran()

  fires <- get_mtbs(years = 2005, output = "sf", verbose = FALSE)
  year_col <- intersect(c("Year", "YEAR", "year"), names(fires))

  if (length(year_col) > 0) {
    yrs <- as.integer(fires[[year_col[[1L]]]])
    expect_true(all(yrs == 2005, na.rm = TRUE))
  }
})
