# rmon 1.1.0

## New features

* Added `expr` parameter to `monitor()` for executing arbitrary R expressions when files change, as an alternative to running R scripts via the `file` parameter.

* Added support for natural R syntax using curly braces `{}` for multi-line expressions.

* Added `capture_output` parameter to control whether expression output is captured and displayed (default: `TRUE`).

* Added `on_error` parameter to control behavior when expression execution fails (`"continue"` or `"stop"`).

## Documentation

* Updated function documentation with comprehensive examples showing both string and language object expressions.

* Updated README with detailed examples of expression execution features.

## Testing

* Added comprehensive test suite using `testthat` for CRAN compliance.

# rmon 1.0.0

* Initial CRAN submission.
