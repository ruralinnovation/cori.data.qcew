#' Read processed QCEW data from S3
#'
#' Queries the CORI tidy QCEW parquet files from S3 using DuckDB with the
#' httpfs extension. Returns long-format data — one row per geoid/year/variable.
#'
#' @param vintage Character. The vintage to read — e.g., \code{"2024"}.
#'   Default: \code{"latest"}, which reads the \code{_LATEST} pointer written
#'   by \code{\link{write_qcew_processed_to_s3}}.
#' @param variables Character vector. Variable names to return.
#'   Default: \code{NULL} (all variables). See \code{\link{get_qcew_codebook}}.
#' @param years Integer vector. Years to return. Default: \code{NULL} (all years).
#' @param geoids Character vector. FIPS codes to filter to. Accepts 5-digit
#'   county, 2-digit state, or \code{"00"} for national.
#'   Default: \code{NULL} (all geographies).
#' @param s3_bucket Character. S3 bucket name. Default: \code{"cori.data.qcew"}.
#' @param s3_path_prefix Character. Optional prefix matching the one used in
#'   \code{\link{write_qcew_processed_to_s3}}, e.g. \code{"test/"} for dev
#'   uploads. Default: \code{""} (no prefix).
#'
#' @return A data frame with columns: \code{geoid}, \code{year},
#'   \code{variable}, \code{value}, \code{agg_var}.
#'
#' @seealso \code{\link{latest_qcew_vintage}}, \code{\link{get_qcew_codebook}}
#'
#' @examples
#' \dontrun{
#' # All data, latest vintage
#' df <- read_qcew_from_s3()
#'
#' # Specific variable and years
#' df <- read_qcew_from_s3(
#'   variables = "annual_avg_emplvl",
#'   years     = 2007:2024
#' )
#'
#' # Specific counties
#' df <- read_qcew_from_s3(
#'   geoids = c("54011", "54025"),
#'   years  = 2010:2023
#' )
#' }
#'
#' @export
read_qcew_from_s3 <- function(vintage        = "latest",
                               variables      = NULL,
                               years          = NULL,
                               geoids         = NULL,
                               s3_bucket      = "cori.data.qcew",
                               s3_path_prefix = "") {

  .Deprecated(
    msg = paste0(
      "read_qcew_from_s3() is deprecated and will be removed in a future version.\n",
      "Use domain-specific functions instead:\n",
      "  get_employment()              - total employment\n",
      "  get_wage_salary()             - average annual pay\n",
      "  get_sector_employment()       - employment by sector (BLS or CORI)\n",
      "  get_sector_wages()            - wages by sector (BLS or CORI)\n",
      "  get_employment_concentration() - employment HHI\n",
      "Note: variable names have changed (e.g. annual_avg_emplvl -> employment,\n",
      "  annual_avg_pay -> avg_pay, hhi_emp -> employment_hhi).\n",
      "See get_qcew_codebook() for the full variable reference."
    )
  )

  vintage_tag <- .resolve_vintage(vintage, s3_bucket, s3_path_prefix)

  con <- cori.data.s3::connect_to_s3(s3_bucket)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))

  base_path <- sprintf("s3://%s/%sdata_processed/%s", s3_bucket, s3_path_prefix, vintage_tag)
  glob      <- sprintf("%s/**/*.parquet", base_path)

  query <- sprintf(
    "SELECT geoid, year, variable, value, agg_var FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- .build_where_clauses(geoids = geoids, years = years, variables = variables)
  if (length(where) > 0) {
    query <- paste(query, "WHERE", paste(where, collapse = " AND "))
  }

  DBI::dbGetQuery(con, query) |>
    dplyr::mutate(
      geoid   = as.character(geoid),
      year    = as.integer(year),
      value   = as.numeric(value),
      agg_var = as.numeric(agg_var)
    )
}


# -- Internal helpers ----------------------------------------------------------

# Resolve "latest" to an actual vintage tag by reading the _LATEST pointer.
#' @keywords internal
.resolve_vintage <- function(vintage, s3_bucket, s3_path_prefix = "") {
  if (vintage == "latest") {
    latest_qcew_vintage(s3_bucket)
  } else {
    if (!startsWith(vintage, "vintage_")) sprintf("vintage_%s", vintage) else vintage
  }
}

# Build SQL WHERE clause fragments from filter arguments.
#' @keywords internal
.build_where_clauses <- function(geoids = NULL, years = NULL, variables = NULL) {
  where <- character(0)

  if (!is.null(geoids)) {
    quoted <- paste0("'", geoids, "'", collapse = ", ")
    where  <- c(where, sprintf("geoid IN (%s)", quoted))
  }

  if (!is.null(years)) {
    where <- c(where, sprintf("year IN (%s)", paste(years, collapse = ", ")))
  }

  if (!is.null(variables)) {
    quoted <- paste0("'", variables, "'", collapse = ", ")
    where  <- c(where, sprintf("variable IN (%s)", quoted))
  }

  where
}
