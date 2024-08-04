#' Monitor files for changes
#'
#' @param dir Character vector. Directory to monitor for changes. Can be
#' multiple.
#' @param file String, file path. File to rerun when changes are detected in
#' `dir`.
#' @param ext Character vector. Extensions to watch.
#' @param ignore Character vector. Files or directories to ignore.
#' @param delay Length one numeric. Number of seconds to wait before checking
#' for file changes again.
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
monitor <- function(
    dir = ".",
    file,
    ext = "R",
    ignore = NULL,
    delay = 1) {
  print("monitoring...")
}
