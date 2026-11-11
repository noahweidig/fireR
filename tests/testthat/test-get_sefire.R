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

test_that("get_sefire() warns that years is ignored for single-file datasets, regardless of verbose (#121)", {
  for (ds in c("Fire History", "Burned Area Polygons", "Burned Area Rasters")) {
    for (v in c(TRUE, FALSE)) {
      expect_warning(
        suppressMessages(
          get_sefire(dataset = ds, years = 2020, dry_run = TRUE, verbose = v)
        ),
        "ignored"
      )
    }
  }
})

test_that("get_sefire() returns only ZIP paths that exist after failed downloads", {
  tmp <- file.path(tempdir(), "sefire_partial_fail")
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  ok   <- file.path(tmp, "cbi_mosaic_2020.zip")
  fail <- file.path(tmp, "cbi_mosaic_2021.zip")
  writeLines("x", ok)

  local_mocked_bindings(
    multi_download = function(urls, destfiles, ...) {
      writeLines("partial", destfiles)
      data.frame(
        success     = FALSE,
        url         = urls,
        destfile    = destfiles,
        status_code = 503L
      )
    },
    .package = "curl"
  )

  res <- suppressWarnings(
    get_sefire(years = 2020:2021, directory = tmp, verbose = FALSE)
  )
  expect_equal(basename(as.character(res)), "cbi_mosaic_2020.zip")
  expect_true(file.exists(ok))
  expect_false(file.exists(fail))
})

# ── Integration tests (download required) ────────────────────────────────────

shared_sefire_cache <- file.path(tempdir(), "sefire_shared_test_cache")

test_that("get_sefire() downloads Burn Severity and returns ZIP path", {
  skip_if_sefire_unreachable()
  skip_on_cran()

  zip_paths <- suppressWarnings(
    get_sefire(years = 2020, directory = shared_sefire_cache, verbose = FALSE)
  )
  expect_type(zip_paths, "character")
  expect_true(all(file.exists(zip_paths)))
  expect_true(all(grepl("cbi_mosaic_2020\\.zip$", zip_paths)))
})
