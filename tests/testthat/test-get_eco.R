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
  expect_error(get_nal2eco(cache = c("a", "b")), "logical or character")
  expect_error(get_nal3eco(cache = NA), "logical or character")
  expect_error(get_usl3eco(cache = NULL), "logical or character")
  expect_error(get_usl4eco(cache = list()), "logical or character")
})

test_that("get_eco functions reject invalid verbose argument", {
  expect_error(get_nal1eco(verbose = "yes"), "single logical value")
  expect_error(get_nal2eco(verbose = 1), "single logical value")
  expect_error(get_nal3eco(verbose = NA), "single logical value")
  expect_error(get_usl3eco(verbose = c(TRUE, FALSE)), "single logical value")
  expect_error(get_usl4eco(verbose = NULL), "single logical value")
})

test_that("get_us eco functions reject invalid state argument", {
  expect_error(get_usl3eco(state = "yes"), "single logical value")
  expect_error(get_usl4eco(state = 1), "single logical value")
})
