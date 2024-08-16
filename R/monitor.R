#' Monitor files for changes and rerun specified script
#'
#' @description
#' Monitors specified directories for file changes and reruns a designated
#' R script when changes are detected. It's designed to automate the process
#' of reloading your R applications during development, similar to nodemon
#' for Node.js.
#'
#' @param dir Character vector. Directory or directories to monitor for changes.
#' Defaults to the current working directory.
#' @param file String, file path. Path to the R script to rerun when changes
#' are detected.
#' @param ext Character vector. File extensions to watch.
#' Defaults to `c(".R", ".r")` files.
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
#' \dontrun{
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
#' @return NULL
#' @export
monitor <- function(
    dir = getwd(),
    file,
    ext = c(".R", ".r"),
    exclude_files = NULL,
    exclude_patterns = NULL,
    exclude_dirs = NULL,
    delay = 1) {
  file <- normalizePath(path = file.path(dir[[1]], file))
  if (!file.exists(file)) {
    msg <- sprintf("File '%s' not found!", file)
    stop(msg, call. = FALSE)
  }

  now <- function() {
    format(Sys.time(), "%c")
  }

  dashes <- function() {
    "---------------------------------------------------------"
  }

  cat(
    dashes(),
    sprintf("%s Starting rmon...\n", now()),
    sep = "\n"
  )

  get_file_info <- function() {
    patterns <- paste0(
      "\\.",
      gsub(pattern = "\\.", replacement = "", x = ext),
      collapse = "|"
    )

    files <- list.files(
      path = dir,
      pattern = patterns,
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
        full.names = TRUE,
        recursive = TRUE
      )
      files <- files[!files %in% dirs_to_exclude]
    }

    if (!is.null(exclude_files)) {
      files_to_exclude <- normalizePath(path = file.path(dir, exclude_files))
      files <- files[!files %in% files_to_exclude]
    }

    file.info(files)
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

      cat(
        dashes(),
        sprintf("%s Files changed. Restarting...\n", now()),
        sep = "\n"
      )
      p$kill()

      p <- start_new_process()
    }

    Sys.sleep(time = delay)
  }
}
