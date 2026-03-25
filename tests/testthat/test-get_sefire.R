test_that("get_sefire() rejects invalid dataset argument", {
  expect_error(get_sefire(dataset = "bad"), "bad")
})

test_that("get_sefire() requires years when dataset is Burn Severity", {
  expect_error(get_sefire(dataset = "Burn Severity", years = NULL), "`years` must be provided")
})

test_that("get_sefire() rejects out-of-range years", {
  expect_error(get_sefire(years = 1999), "2000 and 2022")
  expect_error(get_sefire(years = 2023), "2000 and 2022")
})

test_that("get_sefire() rejects NA in years", {
  expect_error(get_sefire(years = c(2010L, NA_integer_)), "no NA values")
})

test_that("get_sefire() rejects empty years vector", {
  expect_error(get_sefire(years = integer(0)), "non-empty")
})
