# Write QCEW data to S3 as partitioned parquet.
# Two functions, two purposes:
#
#   write_qcew_raw_to_s3()       — raw BLS structure, partitioned by year
#   write_qcew_processed_to_s3() — CORI tidy long format, versioned by vintage
#
# S3 layout:
#   data_raw/year=YYYY/part-0.parquet
#   data_processed/vintage_YYYY/year=YYYY/part-0.parquet
#   data_processed/_LATEST   <- contains current vintage name (e.g., "vintage_2024")


#' Return the current latest QCEW vintage name from S3
#'
#' Reads the \code{_LATEST} pointer file written by
#' \code{\link{write_qcew_processed_to_s3}} and returns the vintage string
#' (e.g., \code{"2024"}).
#'
#' @param s3_bucket Character. S3 bucket name. Default: \code{"cori.data.qcew"}.
#'
#' @return Character. The current vintage label (e.g., \code{"vintage_2024"}).
#'
#' @seealso \code{\link{read_qcew_from_s3}}
#'
#' @export
latest_qcew_vintage <- function(s3_bucket = "cori.data.qcew") {
  # Use path-style URL -- virtual-hosted style breaks SSL for bucket names with dots
  url <- sprintf("https://s3.us-east-1.amazonaws.com/%s/data_processed/_LATEST", s3_bucket)
  tryCatch(
    readLines(url, n = 1L, warn = FALSE),
    error = function(e) stop(
      sprintf("Could not read _LATEST pointer from s3://%s. Has write_qcew_processed_to_s3() been run?", s3_bucket)
    )
  )
}


#' Write raw QCEW data to S3 as partitioned parquet
#'
#' Downloads BLS QCEW county high-level files for each year, reads the raw BLS
#' column structure (wide format), and writes year-partitioned parquet files to
#' S3. This is the archival mirror of BLS source files.
#'
#' Intended to be run by the package maintainer when new data is available.
#'
#' @param years Integer vector. Years to pull. Default: \code{1990} to current year.
#' @param staging_dir Character. Local directory for staging downloads.
#'   Default: \code{"data/qcew"}.
#' @param s3_bucket Character. S3 bucket name. Default: \code{"cori.data.qcew"}.
#' @param overwrite Logical. If \code{TRUE}, delete existing S3 year partitions
#'   before uploading. Use when re-publishing years already on S3.
#'   Default: \code{FALSE}.
#' @param sync_to_s3 Logical. Upload to S3 after writing locally. Default: \code{TRUE}.
#'
#' @return Invisibly, total row count written.
#'
#' @seealso \code{\link{write_qcew_processed_to_s3}}
#'
#' @examples
#' \dontrun{
#' # Full run
#' write_qcew_raw_to_s3()
#'
#' # Specific years, local only
#' write_qcew_raw_to_s3(years = 2022:2024, sync_to_s3 = FALSE)
#'
#' # Add a new year when data_raw/ already exists in S3
#' write_qcew_raw_to_s3(years = 2025, overwrite = TRUE)
#' }
#'
#' @keywords internal
#' @export
write_qcew_raw_to_s3 <- function(years       = 1990:as.integer(format(Sys.Date(), "%Y")),
                                  staging_dir = "data/qcew",
                                  s3_bucket   = "cori.data.qcew",
                                  overwrite   = FALSE,
                                  sync_to_s3  = TRUE) {

  out_dir <- file.path(staging_dir, "s3_raw")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  total_rows <- 0L

  for (yr in years) {
    message(sprintf("Reading raw QCEW %d...", yr))
    dta <- tryCatch(
      read_qcew_county_data(yr, staging_dir = staging_dir, keep_industries = TRUE),
      error = function(e) { message(sprintf("  Skipping %d: %s", yr, conditionMessage(e))); NULL }
    )
    if (is.null(dta) || nrow(dta) == 0L) next

    yr_dir <- file.path(out_dir, sprintf("year=%d", yr))
    dir.create(yr_dir, recursive = TRUE, showWarnings = FALSE)

    tbl_name <- sprintf("raw_%d", yr)
    DBI::dbWriteTable(con, tbl_name, dta, overwrite = TRUE)
    DBI::dbExecute(con, sprintf(
      "COPY %s TO '%s' (FORMAT 'parquet', OVERWRITE_OR_IGNORE)",
      tbl_name, file.path(yr_dir, "part-0.parquet")
    ))

    total_rows <- total_rows + nrow(dta)
    message(sprintf("  %s rows written for %d", format(nrow(dta), big.mark = ","), yr))
  }

  message(sprintf("Raw parquet written to %s (%s total rows)", out_dir,
                  format(total_rows, big.mark = ",")))

  if (sync_to_s3) {
    if (overwrite) {
      for (yr in years) {
        s3_uri <- sprintf("s3://%s/data_raw/year=%d/", s3_bucket, yr)
        message(sprintf("Deleting existing S3 prefix: %s", s3_uri))
        system2("aws", args = c("s3", "rm", s3_uri, "--recursive"))
      }
    }
    .upload_to_s3(s3_bucket, "data_raw/", out_dir)
  }

  invisible(total_rows)
}


#' Write processed QCEW data to S3 as a versioned vintage
#'
#' Processes all QCEW data from 1990 to the present into the CORI tidy long
#' format and writes a complete snapshot to S3. Each call creates a new vintage.
#' A \code{_LATEST} pointer file is also updated so \code{\link{read_qcew_from_s3}}
#' can find the current vintage automatically.
#'
#' The processed output contains one row per geoid/year/variable, with columns
#' \code{geoid}, \code{year}, \code{variable}, \code{value}, and \code{agg_var}.
#' See \code{\link{get_qcew_codebook}} for variable definitions.
#'
#' @param vintage Character or \code{NULL}. Vintage label to use (e.g.,
#'   \code{"2024"}). If \code{NULL} (default), derived from \code{max(years)}.
#' @param years Integer vector. Years to include. Default: \code{1990} to
#'   current year.
#' @param staging_dir Character. Local staging directory for BLS downloads.
#'   Default: \code{"data/qcew"}.
#' @param s3_bucket Character. S3 bucket name. Default: \code{"cori.data.qcew"}.
#' @param s3_path_prefix Character. Optional prefix for all S3 keys, e.g.
#'   \code{"test/"} during development. Default: \code{""} (no prefix).
#' @param overwrite Logical. If \code{TRUE}, delete the existing S3 vintage
#'   prefix before uploading. Use when re-publishing the same vintage.
#'   Default: \code{FALSE}.
#' @param sync_to_s3 Logical. Upload to S3 after writing locally. Default: \code{TRUE}.
#'
#' @return Invisibly, a named list: \code{$vintage} and \code{$n_rows}.
#'
#' @seealso \code{\link{write_qcew_raw_to_s3}}, \code{\link{read_qcew_from_s3}},
#'   \code{\link{get_qcew_codebook}}
#'
#' @examples
#' \dontrun{
#' # Full run -- auto-names vintage from data
#' write_qcew_processed_to_s3()
#'
#' # Local only, scoped years
#' write_qcew_processed_to_s3(
#'   years      = 2019:2024,
#'   sync_to_s3 = FALSE
#' )
#'
#' # Re-publish same vintage after adding data
#' write_qcew_processed_to_s3(vintage = "2024", overwrite = TRUE)
#' }
#'
#' @keywords internal
#' @export
write_qcew_processed_to_s3 <- function(vintage        = NULL,
                                        years          = 1990:as.integer(format(Sys.Date(), "%Y")),
                                        staging_dir    = "data/qcew",
                                        s3_bucket      = "cori.data.qcew",
                                        s3_path_prefix = "",
                                        overwrite      = FALSE,
                                        sync_to_s3     = TRUE) {

  # -- Process data ------------------------------------------------------------
  message("Pulling employment...")
  emp <- pull_employment(years, staging_dir = staging_dir)

  message("Pulling sectoral employment shares...")
  sect_emp <- pull_sectoral_employment(years, staging_dir = staging_dir)

  message("Pulling average annual pay...")
  pay <- pull_annual_pay(years, staging_dir = staging_dir)

  message("Pulling sectoral average pay...")
  sect_pay <- pull_sectoral_pay(years, staging_dir = staging_dir)

  message("Pulling HHI...")
  hhi <- pull_hhi(years, staging_dir = staging_dir)

  processed <- dplyr::bind_rows(emp, sect_emp, pay, sect_pay, hhi)

  # -- Derive vintage ----------------------------------------------------------
  if (is.null(vintage)) {
    vintage <- as.character(max(processed$year, na.rm = TRUE))
    message(sprintf("Vintage: %s", vintage))
  }

  vintage_tag <- sprintf("vintage_%s", vintage)

  # -- Write parquet locally ---------------------------------------------------
  out_dir <- file.path(staging_dir, "s3_processed", vintage_tag)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbWriteTable(con, "processed", processed, overwrite = TRUE)
  DBI::dbExecute(con, sprintf(
    "COPY processed TO '%s' (FORMAT 'parquet', PARTITION_BY (year), OVERWRITE_OR_IGNORE)",
    out_dir
  ))

  message(sprintf(
    "Processed parquet written: %s rows to %s",
    format(nrow(processed), big.mark = ","), out_dir
  ))

  # -- Write _LATEST pointer ---------------------------------------------------
  latest_dir  <- file.path(staging_dir, "s3_processed")
  latest_file <- file.path(latest_dir, "_LATEST")
  writeLines(vintage_tag, latest_file)

  # -- Upload to S3 ------------------------------------------------------------
  if (sync_to_s3) {
    s3_vintage_prefix <- sprintf("%sdata_processed/%s/", s3_path_prefix, vintage_tag)

    if (overwrite) {
      s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_vintage_prefix)
      message(sprintf("Deleting existing S3 prefix: %s", s3_uri))
      system2("aws", args = c("s3", "rm", s3_uri, "--recursive"))
    }

    .upload_to_s3(s3_bucket, s3_vintage_prefix, out_dir)
    .upload_to_s3(s3_bucket,
                  sprintf("%sdata_processed/_LATEST", s3_path_prefix),
                  latest_file)
    message(sprintf("_LATEST updated to: %s", vintage_tag))
  }

  invisible(list(vintage = vintage, n_rows = nrow(processed)))
}


# -- Internal helpers ----------------------------------------------------------

# Upload a local path to S3.
# Directories: uses cori.db::put_s3_objects_recursive.
# Single files (e.g. _LATEST): uses aws s3 cp directly.
#' @keywords internal
.upload_to_s3 <- function(s3_bucket, s3_prefix, local_path) {
  message(sprintf("Uploading to s3://%s/%s...", s3_bucket, s3_prefix))

  if (file.info(local_path)$isdir) {
    if (!requireNamespace("cori.db", quietly = TRUE)) {
      stop("cori.db is required for S3 upload. Install with: devtools::install_github('ruralinnovation/cori.db')")
    }
    cori.db::put_s3_objects_recursive(
      bucket_name   = s3_bucket,
      s3_key_prefix = s3_prefix,
      dir_path      = local_path
    )
  } else {
    s3_uri    <- sprintf("s3://%s/%s", s3_bucket, s3_prefix)
    exit_code <- base::system2("aws", args = c("s3", "cp", local_path, s3_uri))
    if (exit_code != 0) stop(sprintf("aws s3 cp failed: %s -> %s", local_path, s3_uri))
  }
}
