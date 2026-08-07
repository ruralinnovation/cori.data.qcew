#' Read raw BLS QCEW county data for a single year
#'
#' Downloads (if needed), unzips, and reads the BLS QCEW county high-level
#' Excel file for the given year. Returns the raw BLS data with cleaned column
#' names and normalized geoids.
#'
#' @param year Integer. Year to read (1990 or later).
#' @param staging_dir Character. Directory containing zip files. Default: \code{"data/qcew"}.
#' @param keep_industries Logical. If \code{FALSE} (default), return only the
#'   all-industry total row. If \code{TRUE}, return all industry rows.
#'
#' @keywords internal
read_qcew_county_data <- function(year, staging_dir = "data/qcew", keep_industries = FALSE) {

  year_dir <- file.path(staging_dir, as.character(year))
  zip_path <- file.path(staging_dir, sprintf("%d_qcew.zip", year))

  needs_unzip <- !dir.exists(year_dir) ||
                 length(list.files(year_dir, recursive = TRUE)) == 0

  if (needs_unzip) {
    if (!file.exists(zip_path)) download_qcew(year, staging_dir)
    message(sprintf("Unzipping QCEW %d...", year))
    dir.create(year_dir, recursive = TRUE, showWarnings = FALSE)
    utils::unzip(zip_path, exdir = year_dir)
  }

  xlsx_files <- list.files(year_dir, pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE)
  if (length(xlsx_files) == 0) stop(sprintf("No xlsx files found in %s", year_dir))

  year_suffix <- stringr::str_sub(as.character(year), -2, -1)
  annual_file <- xlsx_files[grepl(paste0("n", year_suffix, "\\.xlsx$"), xlsx_files)]

  if (length(annual_file) > 0) {
    dta <- readxl::read_xlsx(annual_file[1])
  } else {
    # Fall back to latest available quarterly file
    qtrly_files <- xlsx_files[grepl(paste0("allhlcn", year_suffix, "[1-4]\\.xlsx$"), xlsx_files)]
    if (length(qtrly_files) == 0) stop(sprintf("No annual or quarterly file found for %d", year))

    quarters   <- as.integer(stringr::str_extract(basename(qtrly_files), "[1-4](?=\\.xlsx$)"))
    latest_qtr <- qtrly_files[which.max(quarters)]
    message(sprintf("No annual file for %d -- using %s", year, basename(latest_qtr)))
    dta <- readxl::read_xlsx(latest_qtr)

    # Derive annual equivalents from the single quarter
    qtr <- as.character(unique(dta$Qtr)[1])
    month_cols <- list(
      "1" = c("January Employment",   "February Employment",  "March Employment"),
      "2" = c("April Employment",     "May Employment",       "June Employment"),
      "3" = c("July Employment",      "August Employment",    "September Employment"),
      "4" = c("October Employment",   "November Employment",  "December Employment")
    )
    cols <- month_cols[[qtr]]
    dta <- dta |>
      dplyr::mutate(
        `Annual Average Employment` = (!!rlang::sym(cols[1]) + !!rlang::sym(cols[2]) + !!rlang::sym(cols[3])) / 3,
        `Annual Average Pay`        = `Average Weekly Wage` * 52
      )
  }

  # Normalize geographies
  dta <- dta |>
    dplyr::rename(geoid = "Area\r\nCode") |>
    dplyr::mutate(
      geoid = dplyr::case_when(
        geoid == "US000" ~ "00",
        Cnty  == "000"   ~ St,
        TRUE             ~ geoid
      )
    ) |>
    dplyr::filter(
      stringr::str_sub(geoid, 3, 5) != "999",
      stringr::str_sub(geoid, 1, 1) != "C"
    )

  if (!keep_industries) {
    dta <- dta |> dplyr::filter(NAICS == "10", Own == "0")
  }

  dta |>
    dplyr::mutate(year = as.integer(year)) |>
    janitor::clean_names()
}
