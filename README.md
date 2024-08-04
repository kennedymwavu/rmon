# rmon

R's equivalent of [nodemon](https://nodemon.io/). Designed to make development easier by automatically reloading your R scripts and applications.

can be used to auto-reload:

- arbitrary R scripts
- apps & apis:
  - shiny
  - ambiorix
  - plumber

**rmon** will monitor your source files for any changes and automatically restart/rerun your server. this allows you to focus on coding without manually restarting your server every time you make a change.

just like nodemon, **rmon** is perfect for development.

# Installation

Install the dev version from GitHub:

```r
remotes::install_github(repo = "kennedymwavu/rmon")
```

# Usage

```r
rmon::monitor(
  dir = ".",
  file = "app.R"
)
```

- `dir`: character vector. directory to monitor for changes
- `file`: file to rerun when changes are detected in the directory

# monitoring multiple directories

```r
rmon::monitor(
  dir = c(".", "path-to-another-dir"),
  file = "app.R"
)
```

# specify extension watch list

by default, `{rmon}` monitors only `.R` files in `dir` for changes.

to watch `.R`, `.html`, `.css` and `.js` files:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  ext = c("R", "html", "css", "js")
)
```

- `ext`: character vector. extensions to watch.

specifying `ext = "*"` watches all files in `dir` for changes.

# ignoring files

to ignore the file `dev.R`, do:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  ignore = "dev.R"
)
```

- `ignore`: character vector

to ignore the directory `test/` as well:

```r
rmon::monitor(
  dir = ".",
  file = "app.R",
  ignore = c("dev.R", "test")
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
