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
