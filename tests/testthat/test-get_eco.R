test_that("get_eco functions reject invalid state, verbose, and dry_run arguments", {
  # Test verbose via one of the nal*eco functions
  expect_error(get_nal1eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_nal1eco(verbose = NA), "TRUE.*FALSE")
  expect_error(get_nal2eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_nal2eco(verbose = NA), "TRUE.*FALSE")
  expect_error(get_nal3eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_nal3eco(verbose = NA), "TRUE.*FALSE")
  expect_error(get_usl4eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_usl4eco(verbose = NA), "TRUE.*FALSE")
  expect_error(get_usl4eco(state = "yes"), "TRUE.*FALSE")
  expect_error(get_usl4eco(state = NA), "TRUE.*FALSE")
  expect_error(get_nal1eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_nal1eco(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_nal1eco(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  # Test state and verbose via usl3eco
  expect_error(get_usl3eco(state = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(state = NA), "TRUE.*FALSE")
  expect_error(get_usl3eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(verbose = NA), "TRUE.*FALSE")
  expect_error(get_usl3eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_usl3eco(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  # Test remaining get_*eco functions for dry_run
  expect_error(get_nal2eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_nal2eco(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_nal2eco(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  expect_error(get_nal3eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_nal3eco(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_nal3eco(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")

  expect_error(get_usl4eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_usl4eco(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_usl4eco(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")
})

test_that("get_nal1eco() rejects invalid output argument", {
  expect_error(get_nal1eco(output = "bad"), "bad")
})

test_that("get_nal2eco() rejects invalid output argument", {
  expect_error(get_nal2eco(output = "bad"), "bad")
})

test_that("get_nal3eco() rejects invalid output argument", {
  expect_error(get_nal3eco(output = "bad"), "bad")
})

test_that("get_usl3eco() rejects invalid output argument", {
  expect_error(get_usl3eco(output = "bad"), "bad")
})

test_that("get_usl4eco() rejects invalid output argument", {
  expect_error(get_usl4eco(output = "bad"), "bad")
})

test_that("get_eco functions reject invalid cache argument", {
  expect_error(get_nal1eco(cache = 123), "logical or character")
  expect_error(get_nal1eco(cache = NA), "logical or character")
  expect_error(get_nal1eco(cache = NA_character_), "logical or character")
  expect_error(get_nal2eco(cache = c("a", "b")), "logical or character")
  expect_error(get_nal2eco(cache = NA), "logical or character")
  expect_error(get_nal2eco(cache = NA_character_), "logical or character")
  expect_error(get_nal3eco(cache = NA), "logical or character")
  expect_error(get_nal3eco(cache = NA_character_), "logical or character")
  expect_error(get_nal1eco(cache = NA), "logical or character")
  expect_error(get_nal2eco(cache = NA), "logical or character")
  expect_error(get_usl3eco(cache = NA), "logical or character")
  expect_error(get_usl4eco(cache = NA), "logical or character")
  expect_error(get_usl3eco(cache = NULL), "logical or character")
  expect_error(get_usl3eco(cache = NA), "logical or character")
  expect_error(get_usl3eco(cache = NA_character_), "logical or character")
  expect_error(get_usl4eco(cache = list()), "logical or character")
  expect_error(get_usl4eco(cache = NA), "logical or character")
  expect_error(get_usl4eco(cache = NA_character_), "logical or character")
})

test_that("get_eco functions reject invalid timeout argument", {
  expect_error(get_nal1eco(timeout = "3600"), "positive number")
  expect_error(get_nal1eco(timeout = -1), "positive number")
  expect_error(get_nal1eco(timeout = NA_real_), "positive number")
  expect_error(get_nal1eco(timeout = c(10, 20)), "positive number")

  expect_error(get_nal2eco(timeout = "3600"), "positive number")
  expect_error(get_nal2eco(timeout = -1), "positive number")
  expect_error(get_nal2eco(timeout = NA_real_), "positive number")
  expect_error(get_nal2eco(timeout = c(10, 20)), "positive number")

  expect_error(get_nal3eco(timeout = "3600"), "positive number")
  expect_error(get_nal3eco(timeout = -1), "positive number")
  expect_error(get_nal3eco(timeout = NA_real_), "positive number")
  expect_error(get_nal3eco(timeout = c(10, 20)), "positive number")

  expect_error(get_usl3eco(timeout = "3600"), "positive number")
  expect_error(get_usl3eco(timeout = -1), "positive number")
  expect_error(get_usl3eco(timeout = NA_real_), "positive number")
  expect_error(get_usl3eco(timeout = c(10, 20)), "positive number")

  expect_error(get_usl4eco(timeout = "3600"), "positive number")
  expect_error(get_usl4eco(timeout = -1), "positive number")
  expect_error(get_usl4eco(timeout = NA_real_), "positive number")
  expect_error(get_usl4eco(timeout = c(10, 20)), "positive number")
})

test_that("get_eco functions reject invalid overwrite argument", {
  expect_error(get_nal1eco(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_nal1eco(overwrite = NA), "TRUE.*FALSE")
  expect_error(get_nal1eco(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")

  expect_error(get_nal2eco(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_nal2eco(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_nal3eco(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_nal3eco(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_usl3eco(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_usl4eco(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_usl4eco(overwrite = NA), "TRUE.*FALSE")
  expect_error(get_usl4eco(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
})

test_that("get_eco functions dry_run returns invisible paths without downloading", {
  tmp <- tempdir()

  expect_message(
    res1 <- get_nal1eco(cache = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_invisible(get_nal1eco(cache = tmp, dry_run = TRUE))
  expect_equal(as.character(res1), as.character(fs::path(tmp, "na_cec_eco_l1.zip")))
  expect_false(file.exists(res1))

  expect_message(
    res2 <- get_usl3eco(cache = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_equal(as.character(res2), as.character(fs::path(tmp, "us_eco_l3.zip")))
  expect_false(file.exists(res2))
})
