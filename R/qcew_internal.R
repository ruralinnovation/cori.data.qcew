# Internal helpers for get_employment(), get_wage_salary(), get_sector_employment(),
# get_sector_wages(), and get_employment_concentration().
# Not exported.

# BLS NAICS industry variable prefixes (match the processed parquet variable names)
QCEW_BLS_PREFIXES <- c(
  "natural_resources_mining",
  "construction",
  "manufacturing",
  "trade_transportation_utilities",
  "information",
  "financial_activities",
  "professional_business_services",
  "education_health_services",
  "leisure_hospitality",
  "other_services",
  "public_administration"
)

# Human-readable labels aligned with QCEW_BLS_PREFIXES
QCEW_BLS_LABELS <- c(
  "Natural Resources & Mining",
  "Construction",
  "Manufacturing",
  "Trade, Transportation & Utilities",
  "Information",
  "Financial Activities",
  "Professional & Business Services",
  "Education & Health Services",
  "Leisure & Hospitality",
  "Other Services",
  "Public Administration"
)

QCEW_CORI_SECTORS <- c("tradable_goods", "tradable_services", "local_services")

QCEW_CORI_LABELS  <- c("Tradable Goods", "Tradable Services", "Local Services")


#' Query QCEW data from S3 via DuckDB
#'
#' Internal query engine for all `get_*()` functions. Connects to S3 using
#' [cori.data.s3::connect_to_s3()], builds a DuckDB query against hive-partitioned
#' parquet files, and returns long-format results.
#'
#' @param variables Character vector. Raw variable names (e.g. "annual_avg_emplvl").
#' @param years Integer vector or `NULL`. Years to filter; `NULL` returns all.
#' @param geoids Character vector or `NULL`. FIPS codes to filter; `NULL` returns all.
#' @param geography Character. `"county"`, `"state"`, or `NULL` (both).
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.qcew"`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`, `agg_var`.
#'
#' @importFrom cori.data.s3 connect_to_s3
#'
#' @keywords internal
.qcew_query <- function(
  variables  = NULL,
  years      = NULL,
  geoids     = NULL,
  geography  = NULL,
  s3_bucket  = "cori.data.qcew"
) {

  vintage_tag <- .resolve_vintage("latest", s3_bucket)

  con <- cori.data.s3::connect_to_s3(s3_bucket)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))

  glob  <- sprintf("s3://%s/data_processed/%s/**/*.parquet", s3_bucket, vintage_tag)
  query <- sprintf(
    "SELECT geoid, year, variable, value, agg_var FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- .build_where_clauses(geoids = geoids, years = years, variables = variables)

  # Geography filter — only applied when geoids is not provided
  if (!is.null(geography) && is.null(geoids)) {
    geo_len <- if (geography == "county") 5L else 2L
    where   <- c(where, sprintf("LENGTH(CAST(geoid AS VARCHAR)) = %d", geo_len))
  }

  if (length(where) > 0) {
    query <- paste(query, "WHERE", paste(where, collapse = " AND "))
  }

  result <- DBI::dbGetQuery(con, query)

  dplyr::mutate(result,
    geoid   = as.character(geoid),
    year    = as.integer(year),
    value   = as.numeric(value),
    agg_var = as.numeric(agg_var)
  )
}


# Confirm vintage tag (strips "vintage_" prefix for display)
.qcew_vintage_label <- function(s3_bucket = "cori.data.qcew") {
  tag <- .resolve_vintage("latest", s3_bucket)
  gsub("vintage_", "", tag)
}


# Resolve geography label for confirmation messages
.qcew_geo_label <- function(geography, geoids) {
  if (!is.null(geoids)) return("Filtered")
  switch(geography,
    "county" = "County-level",
    "state"  = "State-level"
  )
}


# Reshape compound variable names (e.g. "construction_emplvl") into
# a sector dimension column + a clean variable name.
#
# @param data       data frame from .qcew_query()
# @param suffix     suffix to strip (e.g. "emplvl", "emp_share", "avg_annual_pay")
# @param new_var    replacement variable name (e.g. "employment", "emp_share", "avg_pay")
# @param keep_agg  logical — include agg_var in output?
.qcew_reshape_sector <- function(data, suffix, new_var, keep_agg = TRUE) {
  data$sector   <- sub(paste0("_", suffix, "$"), "", data$variable)
  data$variable <- new_var

  cols <- c("geoid", "year", "sector", "variable", "value")
  if (keep_agg) cols <- c(cols, "agg_var")
  data[, cols, drop = FALSE]
}


# Emit the standard confirmation message
.qcew_message <- function(data, geo_label, description, vintage_label) {
  message(sprintf(
    "\u2713 %s %s pulled | Years: %d\u2013%d | Rows: %s | Source: BLS QCEW (vintage_%s)",
    geo_label,
    description,
    min(data$year, na.rm = TRUE),
    max(data$year, na.rm = TRUE),
    format(nrow(data), big.mark = ","),
    vintage_label
  ))
}
