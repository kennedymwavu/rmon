# rmon

R's equivalent of [nodemon](https://nodemon.io/). Designed to make development easier by automatically reloading your R scripts and applications or executing arbitrary R expressions when files change.

can be used to:

- auto-reload arbitrary R scripts
- execute custom R expressions on file changes
- auto-reload apps & apis:
  - shiny
  - ambiorix
  - plumber

**rmon** will monitor your source files for any changes and automatically restart/rerun your server or execute your custom R code. this allows you to focus on coding without manually restarting your server every time you make a change.

just like nodemon, **rmon** is perfect for development.

# installation

to install the package from CRAN use:

```r
install.packages("rmon")
```

install the dev version from GitHub:

```r
remotes::install_github(repo = "kennedymwavu/rmon")
```

# usage

## monitoring R scripts

```r
rmon::monitor(
  dir = ".",
  file = "app.R"
)
```

## executing R expressions

```r
rmon::monitor(dir = ".", expr = {
  cat('my custom expression at:', as.character(Sys.time()), '\n')
  # ... rest of your R code here
})
```

**parameters:**

- `dir`: character vector. directory to monitor for changes
- `file`: file to rerun when changes are detected (mutually exclusive with `expr`)
- `expr`: R expression to execute when changes are detected (mutually exclusive with `file`)

# monitoring multiple directories

```r
rmon::monitor(
  dir = c("path-to-first-dir", "path-to-another-dir"),
  file = "app.R"
)
```

if multiple directories are specified, `file` is assumed to be in the first
directory.

# specify extension watch list

by default, `{rmon}` monitors all files in `dir` for changes.

to watch only `.R`, `.html`, `.css` and `.js` files, set the `ext` parameter:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  ext = c("R", "html", "css", "js")
)
```

# ignoring files

to ignore the file `dev.R`, do:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  exclude_files = "dev.R"
)
```

to ignore the directory `test/`:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  exclude_dirs = "test"
)
```

to ignore all files whose names match the pattern `test`:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  exclude_patterns = "test"
)
```

to ignore changes to hidden files, set `monitor_hidden = FALSE`:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  monitor_hidden = FALSE
)
```

# delaying restarting

in some situations, you may want to delay restarting until multiple files have changed.

by default, **rmon** checks for file changes every second.
if you're uploading or modifying multiple files, this can lead to unnecessary multiple restarts of your application.

to delay restarting and avoid this issue, use the `delay` parameter:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  delay = 10
)
```

- `delay`: a length one numeric. number of seconds to wait before checking for file changes again.

# executing expressions

**rmon** now supports executing arbitrary R expressions when files change, providing more flexibility than just rerunning scripts.

## basic expression execution

```r
rmon::monitor(dir = ".", expr = {
  cat("reading some csv file...\n")
  data <- read.csv("data.csv")
  cat("summarizing file contents...\n")
  summary(data)
})
```

## advanced expression features

### error handling

```r
rmon::monitor(
  dir = ".",
  expr = {
    tryCatch(
      {
        source("functions.R")
        cat("Functions reloaded successfully\n")
      },
      error = function(e) {
        cat("Error reloading functions:", e$message, "\n")
      }
    )
  },
  on_error = "continue" # or "stop"
)
```

### output control

```r
# capture and display output (default)
rmon::monitor(
  dir = ".",
  expr = {
    result <- some_analysis()
    print(result)
  },
  capture_output = TRUE
)

# silent execution
rmon::monitor(
  dir = ".",
  expr = {
    log_entry <- paste(Sys.time(), "- Files changed")
    cat(log_entry, file = "changes.log", append = TRUE)
  },
  capture_output = FALSE
)
```

### watch specific file types

```r
rmon::monitor(
  dir = ".",
  ext = c("R", "Rmd"),
  expr = {
    cat("R or Rmd file changed!\n")
    # rebuild documentation, run tests, etc.
  }
)
```
