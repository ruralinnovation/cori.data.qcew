#' Get Total Employment Data
#'
#' Returns average annual employment levels from the BLS Quarterly Census of
#' Employment and Wages (QCEW). Data covers 1990 to the present at the county
#' and state level.
#'
#' @param geography Geographic level: `"county"` (default) or `"state"`.
#' @param geoids Character vector of FIPS codes. Use 5-digit for counties,
#'   2-digit for states. When provided, overrides `geography` for row filtering.
#' @param years Integer vector of years to return (e.g. `2018:2023`).
#'   Default `NULL` returns all available years.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`.
#'   One row per geoid × year. Variable: `employment` (average annual workers).
#'
#' @seealso [get_wage_salary()], [get_sector_employment()], [get_qcew_codebook()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # All counties, all years
#'   emp <- get_employment(geography = "county")
#'
#'   # Specific counties, recent years
#'   emp <- get_employment(geoids = c("33009", "33011"), years = 2018:2023)
#'
#'   # State-level
#'   emp <- get_employment(geography = "state", years = 2015:2023)
#' }
get_employment <- function(geography = "county", geoids = NULL, years = NULL) {

  geography <- match.arg(geography, c("county", "state"))

  raw <- .qcew_query(
    variables = "annual_avg_emplvl",
    years     = years,
    geoids    = geoids,
    geography = geography
  )

  raw$variable <- "employment"
  out <- raw[, c("geoid", "year", "variable", "value"), drop = FALSE]

  .qcew_message(
    out,
    .qcew_geo_label(geography, geoids),
    "employment",
    .qcew_vintage_label()
  )

  out
}


#' Get Average Annual Pay Data
#'
#' Returns BLS-published average annual pay per worker from the Quarterly Census
#' of Employment and Wages (QCEW). Values are nominal dollars — deflate using a
#' BLS price index (e.g. CPI-U or ECI) to convert to real terms. Data covers
#' 1990 to the present at the county and state level.
#'
#' @inheritParams get_employment
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`, `agg_var`.
#'   One row per geoid × year. Variable: `avg_pay` (nominal dollars per worker).
#'   `agg_var` is total employment — the weight for computing employment-weighted
#'   averages across geographies.
#'
#' @seealso [get_employment()], [get_sector_wages()], [get_qcew_codebook()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # All counties
#'   pay <- get_wage_salary(geography = "county", years = 2015:2023)
#'
#'   # Specific state
#'   pay <- get_wage_salary(geoids = "33", years = 2010:2023)
#' }
get_wage_salary <- function(geography = "county", geoids = NULL, years = NULL) {

  geography <- match.arg(geography, c("county", "state"))

  raw <- .qcew_query(
    variables = "annual_avg_pay",
    years     = years,
    geoids    = geoids,
    geography = geography
  )

  raw$variable <- "avg_pay"
  out <- raw[, c("geoid", "year", "variable", "value", "agg_var"), drop = FALSE]

  .qcew_message(
    out,
    .qcew_geo_label(geography, geoids),
    "average annual pay",
    .qcew_vintage_label()
  )

  out
}
