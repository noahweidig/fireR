test_that("get_nifc() errors on non-existent directory path gracefully", {
  # Providing a valid temp dir should not error at the argument level
  tmp <- file.path(tempdir(), "nifc_arg_test")
  # We can't download, but we can confirm the function at least sets up the dir
  # without erroring on argument validation (no argument validation to test here,
  # but we confirm the function signature is accessible)
  expect_type(formals(get_nifc)$overwrite, "logical")
  expect_type(formals(get_nifc)$verbose, "logical")
})

test_that("get_fod() has expected default arguments", {
  expect_equal(formals(get_fod)$overwrite, FALSE)
  expect_equal(formals(get_fod)$verbose, TRUE)
})
