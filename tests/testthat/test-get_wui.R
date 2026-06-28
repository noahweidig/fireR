test_that("get_wui() rejects invalid arguments", {
  expect_error(get_wui(directory = 123), "character string")
  expect_error(get_wui(directory = c("a", "b")), "character string")
  expect_error(get_wui(directory = NA_character_), "character string")

  expect_error(get_wui(overwrite = "yes"), "TRUE.*FALSE")
  expect_error(get_wui(overwrite = c(TRUE, FALSE)), "TRUE.*FALSE")
  expect_error(get_wui(overwrite = NA), "TRUE.*FALSE")

  expect_error(get_wui(timeout = "3600"), "positive number")
  expect_error(get_wui(timeout = -1), "positive number")
  expect_error(get_wui(timeout = NA_real_), "positive number")
  expect_error(get_wui(timeout = c(10, 20)), "positive number")

  expect_error(get_wui(verbose = "yes"), "TRUE.*FALSE")
  expect_error(get_wui(verbose = NA), "TRUE.*FALSE")

  expect_error(get_wui(dry_run = "yes"), "TRUE.*FALSE")
  expect_error(get_wui(dry_run = NA), "TRUE.*FALSE")
  expect_error(get_wui(dry_run = c(TRUE, FALSE)), "TRUE.*FALSE")
})

test_that("get_wui() does not warn when ZIP already exists", {
  tmp <- file.path(tempdir(), "wui_warn_test")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  zip_file <- file.path(tmp, "usfs_wui.zip")

  # Create a fake sentinel ZIP so the function sees it as already downloaded
  writeLines("fake", zip_file)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  # With file present, no warning should be emitted and no download attempted
  expect_no_warning(
    get_wui(directory = tmp, overwrite = FALSE, verbose = FALSE)
  )
})

test_that("get_wui() has expected default arguments", {
  expect_equal(formals(get_wui)$overwrite, FALSE)
  expect_equal(formals(get_wui)$verbose, TRUE)
})

test_that("get_wui() dry_run returns invisible path without downloading", {
  tmp <- tempdir()

  expect_message(
    res1 <- get_wui(directory = tmp, dry_run = TRUE),
    "Dry run: Would download"
  )
  expect_invisible(get_wui(directory = tmp, dry_run = TRUE))
  expect_equal(as.character(res1), as.character(fs::path(tmp, "usfs_wui.zip")))
  expect_false(file.exists(res1))
})
