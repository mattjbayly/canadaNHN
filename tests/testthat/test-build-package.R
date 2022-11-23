test_that("Test Build Package", {

  # ---------------------------------------------------
  expect_true(1 == 1)

  # ---------------------------------------------------
  # Not run
  if(FALSE) {

    library(usethis)
    library(testthat)
    library(rhub)
    library(devtools)
    library(usethis)
    library(qpdf)
    library(testthat)

    # Loading unfinished package to memory...
    rm(list = ls())
    devtools::load_all()
    devtools::document()
    devtools::test()  # Run tests
    devtools::check() # Operating system test

  }



})
