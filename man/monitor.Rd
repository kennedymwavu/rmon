% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/monitor.R
\name{monitor}
\alias{monitor}
\title{Monitor files for changes and rerun specified script}
\usage{
monitor(
  dir = getwd(),
  file,
  ext = "*",
  monitor_hidden = TRUE,
  exclude_files = NULL,
  exclude_patterns = NULL,
  exclude_dirs = NULL,
  delay = 1
)
}
\arguments{
\item{dir}{Character vector. Directory or directories to monitor for changes.
Defaults to the current working directory.}

\item{file}{String, file path. Path to the R script to rerun when changes
are detected.}

\item{ext}{Character vector. File extensions to watch.
"*" (the default) watches all files in \code{dir}.}

\item{monitor_hidden}{Logical. Should hidden files be monitored for changes?
Default is \code{TRUE}.
Hidden files are those whose names start with a dot eg. \code{.Renviron}, \code{.env},
etc.
This option is especially helpful when \code{ext = "*"}.}

\item{exclude_files}{Character vector. Specific files to ignore. Changes
to these files will not trigger a script rerun. Default is \code{NULL}.}

\item{exclude_patterns}{Character vector. File name patterns to ignore. Any
files in \code{dir} with names matching these patterns will be ignored. Default
is \code{NULL}.}

\item{exclude_dirs}{Character vector. Directories to exclude from
monitoring. Default is \code{NULL}.}

\item{delay}{Numeric. Number of seconds to wait before checking
for file changes. Defaults to \code{1}.}
}
\description{
Monitors specified directories for file changes and reruns a designated
R script when changes are detected. It's designed to automate the process
of reloading your R applications during development, similar to nodemon
for Node.js.
}
\details{
The monitoring process can be customized by excluding specific files, file
patterns, or entire directories. This allows you to ignore changes to files
that shouldn't trigger a reload (eg. temporary files, log files, etc.).

If multiple directories are supplied, \code{file} is assumed to be in the first
directory.

The function runs indefinitely until interrupted.
}
\examples{
\dontrun{
# monitor current directory, rerun 'app.R' on changes, ignore 'dev.R' and
# any files in 'test/' directory:
rmon::monitor(
  dir = ".",
  file = "app.R",
  exclude_files = "dev.R",
  exclude_dirs = "test"
)

# monitor multiple directories, watch only `.R` & `.Rmd` files:
rmon::monitor(
  dir = c("src", "scripts"),
  file = "main.R",
  ext = c(".R", ".Rmd")
)
}
}
