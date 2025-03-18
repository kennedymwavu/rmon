#' Monitor files for changes and rerun specified script
#'
#' @description
#' Monitors specified directories for file changes and reruns a designated
#' R script when changes are detected. It's designed to automate the process
#' of reloading your R applications during development, similar to nodemon
#' for Node.js.
#'
#' @param dir Character vector. Directory or directories to monitor for changes.
#' @param file String, file path. Path to the R script to rerun when changes
#' are detected.
#' @param ext Character vector. File extensions to watch.
#' "*" (the default) watches all files in `dir`.
#' @param monitor_hidden Logical. Should hidden files be monitored for changes?
#' Default is `FALSE`.
#' Hidden files are those whose names start with a dot eg. `.Renviron`, `.env`,
#' etc.
#' This option is especially helpful when `ext = "*"`.
#' @param exclude_files Character vector. Specific files to ignore. Changes
#' to these files will not trigger a script rerun. Default is `NULL`.
#' @param exclude_patterns Character vector. File name patterns to ignore. Any
#' files in `dir` with names matching these patterns will be ignored. Default
#' is `NULL`.
#' @param exclude_dirs Character vector. Directories to exclude from
#' monitoring. Default is `NULL`.
#' @param delay Numeric. Number of seconds to wait before checking
#' for file changes. Defaults to `1`.
#'
#' @details
#' The monitoring process can be customized by excluding specific files, file
#' patterns, or entire directories. This allows you to ignore changes to files
#' that shouldn't trigger a reload (eg. temporary files, log files, etc.).
#'
#' If multiple directories are supplied, `file` is assumed to be in the first
#' directory.
#'
#' The function runs indefinitely until interrupted.
#' @examples
#' if (interactive()) {
#' # monitor current directory, rerun 'app.R' on changes, ignore 'dev.R' and
#' # any files in 'test/' directory:
#' rmon::monitor(
#'   dir = ".",
#'   file = "app.R",
#'   exclude_files = "dev.R",
#'   exclude_dirs = "test"
#' )
#'
#' # monitor multiple directories, watch only `.R` & `.Rmd` files:
#' rmon::monitor(
#'   dir = c("src", "scripts"),
#'   file = "main.R",
#'   ext = c(".R", ".Rmd")
#' )
#' }
#' @return `NULL`
#' @export
monitor <- function(
  dir,
  file,
  ext = "*",
  monitor_hidden = FALSE,
  exclude_files = NULL,
  exclude_patterns = NULL,
  exclude_dirs = NULL,
  delay = 1
) {
  file <- normalizePath(
    path = file.path(dir[[1]], file[[1]]),
    mustWork = TRUE
  )

  patterns <- paste0(ext, "$", collapse = "|")

  dash_and_msg(type = "starting")

  get_file_info <- function() {
    files <- list.files(
      path = dir,
      pattern = patterns,
      all.files = monitor_hidden,
      full.names = TRUE,
      recursive = TRUE
    )

    if (!is.null(exclude_patterns)) {
      patterns_to_exclude <- grepl(
        pattern = exclude_patterns,
        x = basename(files)
      )
      files <- files[!patterns_to_exclude]
    }

    if (!is.null(exclude_dirs)) {
      dirs_to_exclude <- list.files(
        path = normalizePath(path = file.path(dir, exclude_dirs)),
        pattern = patterns,
        all.files = monitor_hidden,
        full.names = TRUE,
        recursive = TRUE
      )
      files <- files[!files %in% dirs_to_exclude]
    }

    if (!is.null(exclude_files)) {
      files_to_exclude <- normalizePath(path = file.path(dir, exclude_files))
      files <- files[!files %in% files_to_exclude]
    }

    file.info(files)$mtime
  }

  start_new_process <- function() {
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
      dash_and_msg()
      p$kill()
      p <- start_new_process()
    }

    Sys.sleep(time = delay)
  }
}

#' Get current date and time
#'
#' @details Retrieves current system date and time, formatted in
#' a human-readable way.
#' @examples
#' current_time()
#' @return String in the format "YYYY-MM-DD H:M:S" with the
#' timezone appended at the end.
#' @keywords internal
#' @noRd
current_time <- function() {
  format(x = Sys.time(), format = "%F %T", usetz = TRUE)
}

#' Show starting/restarting message on console
#'
#' @param type String. Type of message to show. Either "restarting"(default)
#' or "starting".
#' @examples
#' dash_and_msg()
#' @return `NULL`
#' @keywords internal
#' @noRd
dash_and_msg <- function(type = c("restarting", "starting")) {
  type <- match.arg(arg = type)

  now <- current_time()
  restart_msg <- sprintf("%s Files changed. Restarting...", now)
  start_msg <- sprintf("%s Starting rmon...", now)
  dashes <- strrep(x = "_", times = nchar(restart_msg))

  msg <- switch(
    EXPR = type,
    restarting = restart_msg,
    starting = start_msg
  )

  message(
    dashes,
    "\n",
    msg,
    "\n"
  )
}
