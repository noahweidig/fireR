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
