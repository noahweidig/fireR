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

  expect_error(get_sefire(dataset = "Fire History", dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Fire History", dry_run = NA), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Fire History", dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  expect_error(get_sefire(dataset = "Burned Area Polygons", dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Burned Area Polygons", dry_run = NA), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Burned Area Polygons", dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  expect_error(get_sefire(dataset = "Burned Area Rasters", dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Burned Area Rasters", dry_run = NA), "TRUE.*FALSE")
  expect_error(get_sefire(dataset = "Burned Area Rasters", dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")
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

test_that("get_sefire() rejects logical NA for years", {
  expect_error(get_sefire(years = NA), "non-empty integer")
})

test_that("get_sefire() rejects non-integer numeric years", {
  expect_error(get_sefire(years = 2020.5), "non-empty integer")
})

test_that("get_sefire() dry_run returns invisible paths without downloading", {
  tmp <- tempdir()

  # Burn Severity
  expect_message(
    res1 <- get_sefire(dataset = "Burn Severity", years = 2020, directory = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_invisible(get_sefire(dataset = "Burn Severity", years = 2020, directory = tmp, dry_run = TRUE))
  expect_equal(basename(as.character(res1)), "cbi_mosaic_2020.zip")
  expect_false(file.exists(res1))

  # Fire History
  expect_message(
    res2 <- get_sefire(dataset = "Fire History", directory = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_equal(basename(as.character(res2)), "SEFM_L_FHM_1994_2024.gdb.zip")
  expect_false(file.exists(res2))

  # Burned Area Polygons
  expect_message(
    res3 <- get_sefire(dataset = "Burned Area Polygons", directory = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_equal(basename(as.character(res3)), "SEFM_L_ABA_1994_2024_polys.gdb.zip")
  expect_false(file.exists(res3))

  # Burned Area Rasters
  expect_message(
    res4 <- get_sefire(dataset = "Burned Area Rasters", directory = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_equal(basename(as.character(res4)), "SEFM_L_ABA_1994_2024_rasters.gdb.zip")
  expect_false(file.exists(res4))
})
