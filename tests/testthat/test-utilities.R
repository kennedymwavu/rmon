test_that("current_time() returns properly formatted time", {
  time_str <- rmon:::current_time()
  expect_type(time_str, "character")
  expect_length(time_str, 1)

  # Test basic format (YYYY-MM-DD HH:MM:SS)
  expect_match(time_str, "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}")
})

test_that("dash_and_msg() generates correct messages", {
  # Test starting message
  expect_message(
    rmon:::dash_and_msg(type = "starting"),
    "Starting rmon"
  )

  # Test restarting message
  expect_message(
    rmon:::dash_and_msg(type = "restarting"),
    "Files changed"
  )
})
