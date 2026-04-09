#' Download BLS QCEW county high-level zip file for a single year
#'
#' @param year Integer. Year to download (1990 or later).
#' @param staging_dir Character. Directory to save zip files. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
download_qcew <- function(year, staging_dir = "data/qcew") {

  if (year < 1990) stop("NAICS-era data starts in 1990.")

  dir.create(staging_dir, recursive = TRUE, showWarnings = FALSE)

  zip_path <- file.path(staging_dir, sprintf("%d_qcew.zip", year))

  if (file.exists(zip_path)) {
    message(sprintf("Already downloaded: %s", zip_path))
    return(invisible(zip_path))
  }

  url <- sprintf(
    "https://data.bls.gov/cew/data/files/%d/xls/%d_all_county_high_level.zip",
    year, year
  )

  message(sprintf("Downloading QCEW %d from BLS...", year))
  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = 600)
  utils::download.file(url, zip_path, mode = "wb", quiet = FALSE)
  message(sprintf("Saved to %s", zip_path))

  invisible(zip_path)
}
