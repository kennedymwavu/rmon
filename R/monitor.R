#' Monitor files for changes
#'
#' @param dir Character vector. Directory to monitor for changes. Can be
#' multiple. Defaults to the directory from where this function is called from.
#' @param file String, file path. File to rerun when changes are detected in
#' `dir`.
#' @param ext Character vector. Extensions to watch. Defaults to `.R` files.
#' @param exclude_files Character vector. Files to exclude. Changes to these
#' files will not cause a restart/reload of your script. Default is `NULL`.
#' @param exclude_patterns Character vector. File patterns to exclude.
#' @param exclude_dirs Character vector. Directories to exclude.
#' @param delay Length one numeric. Number of seconds to wait before checking
#' for file changes again. Defaults to `1`.
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
  exclude_files = NULL,
  exclude_patterns = NULL,
  exclude_dirs = NULL,
  delay = 1
) {
  file <- file.path(dir, file) |> normalizePath()
  if (!file.exists(file)) {
    msg <- sprintf("File '%s' not found!", file)
    stop(msg, call. = FALSE)
  }

  now <- \() format(Sys.time(), "%c")
  dashes <- \() "---------------------------------------------------------"

  cat(
    dashes(),
    sprintf("%s Starting rmon...\n", now()),
    sep = "\n"
  )

  get_file_info <- \() {
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

    to_exclude <- character()

    if (!is.null(exclude_dirs)) {
      dirs_to_exclude <- file.path(dir, exclude_dirs) |>
        normalizePath() |>
        list.files(
          pattern = patterns,
          full.names = TRUE,
          recursive = TRUE
        )
      to_exclude <- c(to_exclude, dirs_to_exclude)
    }

    if (!is.null(exclude_files)) {
      files_to_exclude <- file.path(dir, exclude_files) |> normalizePath()
      to_exclude <- c(to_exclude, files_to_exclude)
    }

    to_exclude <- unique(to_exclude)

    files <- files[!files %in% to_exclude]

    file.info(files)
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
        sprintf("%s Files changed. Restarting...\n", now()),
        sep = "\n"
      )
      p$kill()

      p <- start_new_process()
    }

    Sys.sleep(time = delay)
  }
}
