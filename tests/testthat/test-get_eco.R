test_that("get_eco functions reject invalid state and verbose arguments", {
  # Test verbose via one of the nal*eco functions
  expect_error(get_nal1eco(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_nal1eco(verbose = NA), "TRUE.*FALSE")

  # Test state and verbose via usl3eco
  expect_error(get_usl3eco(state = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(state = NA), "TRUE.*FALSE")
  expect_error(get_usl3eco(verbose = "yes"), "TRUE.*FALSE")

  # Test dry_run via usl3eco
  expect_error(get_usl3eco(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_usl3eco(dry_run = NA), "TRUE.*FALSE")
})

test_that("get_eco functions respect dry_run", {
  tmp <- file.path(tempdir(), "eco_dryrun_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  res <- get_nal1eco(cache = tmp, dry_run = TRUE, verbose = FALSE)
  expect_type(res, "character")
  expect_true(grepl("na_cec_eco_l1\\.zip$", res))
  expect_false(file.exists(res))
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
  expect_error(get_usl3eco(cache = NULL), "logical or character")
  expect_error(get_usl3eco(cache = NA), "logical or character")
  expect_error(get_usl3eco(cache = NA_character_), "logical or character")
  expect_error(get_usl4eco(cache = list()), "logical or character")
  expect_error(get_usl4eco(cache = NA), "logical or character")
  expect_error(get_usl4eco(cache = NA_character_), "logical or character")
})

test_that("get_eco functions reject invalid timeout argument", {
  expect_error(get_nal1eco(timeout = "3600"), "positive number")
  expect_error(get_nal2eco(timeout = -1), "positive number")
  expect_error(get_nal3eco(timeout = NA_real_), "positive number")
  expect_error(get_usl3eco(timeout = c(10, 20)), "positive number")
  expect_error(get_usl4eco(timeout = list()), "positive number")
})
