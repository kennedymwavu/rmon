test_that("monitor() basic parameter validation", {
  # Test missing parameters
  expect_error(
    monitor(dir = "."),
    "Either 'file' or 'expr' must be provided"
  )

  # Test mutually exclusive parameters
  expect_error(
    monitor(dir = ".", file = "test.R", expr = "print('test')"),
    "'file' and 'expr' are mutually exclusive"
  )

  # Test invalid expression types
  expect_error(
    monitor(dir = ".", expr = 123),
    "'expr' must be a character string, expression, or language object"
  )
})

test_that("substitute mechanism for expressions", {
  # Test that substitute() captures language objects correctly
  # This is the core mechanism enabling expr = {} syntax
  test_expr <- quote({
    x <- 1
    x
  })
  expect_true(is.language(test_expr))
  expect_equal(class(test_expr), "{")

  # Test evaluation
  result <- eval(test_expr)
  expect_equal(result, 1)
})

