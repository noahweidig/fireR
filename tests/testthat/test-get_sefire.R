test_that("get_sefire() rejects invalid dataset argument", {
  expect_error(get_sefire(dataset = "bad"), "bad")
})

test_that("get_sefire() rejects invalid common arguments", {
  expect_error(get_sefire(dataset = "Fire History", directory = 123), "character string")
  expect_error(get_sefire(dataset = "Fire History", directory = c("a", "b")), "character string")
  expect_error(get_sefire(dataset = "Fire History", directory = NA_character_), "character string")

  expect_error(get_sefire(dataset = "Fire History", overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Fire History", overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Fire History", overwrite = NA), "TRUE.*FALSE")

  expect_error(get_sefire(dataset = "Fire History", timeout = "3600"), "positive number")
  expect_error(get_sefire(dataset = "Fire History", timeout = -1), "positive number")
  expect_error(get_sefire(dataset = "Fire History", timeout = NA_real_), "positive number")
  expect_error(get_sefire(dataset = "Fire History", timeout = c(10, 20)), "positive number")

  expect_error(get_sefire(dataset = "Fire History", verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Fire History", verbose = NA), "TRUE.*FALSE")
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

test_that("get_sefire() rejects non-numeric years", {
  expect_error(get_sefire(years = "bad"), "non-empty")
})

test_that("get_sefire() rejects non-integer numeric years", {
  expect_error(get_sefire(years = 2020.5), "non-empty integer")
})
