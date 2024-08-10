#' Monitor files for changes
#'
#' @param dir Character vector. Directory to monitor for changes. Can be
#' multiple. Defaults to the directory from where this function is called from.
#' @param file String, file path. File to rerun when changes are detected in
#' `dir`.
#' @param ext Character vector. Extensions to watch. Defaults to `.R` files.
#' @param ignore Character vector. Files or directories to ignore. Default is
#' `NULL`.
#' @param delay Length one numeric. Number of seconds to wait before checking
#' for file changes again. Defaults to `1`.
#' @param log_file String, file path. Log file. Defaults to `NULL`.
#' @param clear_log_file Logical. Clear log file on each change? Defaults to
#' `FALSE`.
#' @examples
#' \dontrun{
#' rmon::monitor(
#'   dir = ".",
#'   file = "app.R",
#'   ignore = c("dev.R", "test")
#' )
#' }
#' @return NULL
#' @export
monitor <- \(
  dir = getwd(),
  file,
  ext = "R",
  ignore = NULL,
  delay = 1,
  log_file = NULL,
  clear_log_file = FALSE
) {
  file <- file.path(dir, file) |> normalizePath()
  if (!file.exists(file)) {
    msg <- sprintf("File '%s' not found!", file)
    stop(msg, call. = FALSE)
  }

  log_file <- normalizePath(log_file)
  if (!file.exists(log_file)) {
    msg <- sprintf(
      "Log file not found. Path '%s' does not exist!",
      log_file
    )
    stop(msg, call. = FALSE)
  }

  now <- \() format(Sys.time(), "%c")
  dashes <- \() "---------------------------------------------------------"

  cat(
    dashes(),
    sprintf("%s Starting rmon...", now()),
    dashes(),
    sep = "\n"
  )

  get_file_info <- \() {
    patterns <- paste0(
      "\\.",
      gsub(pattern = "\\.", replacement = "", x = ext),
      collapse = "|"
    )

    list.files(
      path = dir,
      pattern = patterns,
      full.names = TRUE
    ) |>
      file.info()
  }


  start_new_process <- \() {
    processx::process$new(
      command = "Rscript",
      args = file,
      stdout = "",
      stderr = "2>&1"
    )
  }


  file_info <- get_file_info()
  p <- start_new_process()
  on.exit(p$kill())

  repeat {
    new_file_info <- get_file_info()
    changed <- !identical(file_info, new_file_info)
    if (changed) {
      file_info <- new_file_info

      cat(
        dashes(),
        "Files changed. Restarting...",
        sep = "\n"
      )
      p$kill()

      if (clear_log_file) {
        cat("", file = log_file, sep = "\n", append = FALSE)
      }

      p <- start_new_process()
      cat(
        paste(now(), "Success!"),
        dashes(),
        sep = "\n"
      )
    }

    Sys.sleep(time = delay)
  }
}
