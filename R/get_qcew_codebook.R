#' Get the cori.data.qcew variable codebook
#'
#' Returns documentation for all variables exposed by the public `get_*`
#' functions, including variable names, descriptions, units, and which
#' function returns each variable.
#'
#' @return A data frame with columns:
#'   - `variable`: Column name as it appears in `get_*` function output
#'   - `source_function`: Pipe-separated list of functions that return this variable
#'   - `raw_variable`: Original BLS/processed variable name (or "derived")
#'   - `description`: Plain-language description
#'   - `unit`: Unit of measurement
#'   - `category`: Variable category
#'   - `agg_var_description`: What `agg_var` represents for this variable
#'     (`NA` if `agg_var` is not returned by the source function)
#'
#' @details
#' All `get_*` functions return tidy (long) format. The `variable` column
#' identifies the metric; `value` holds the numeric result. Sector functions
#' add a `sector` dimension column. Where `agg_var` is returned, it carries
#' the employment weight used for computing employment-weighted averages
#' across geographies.
#'
#' @seealso [get_employment()], [get_wage_salary()], [get_sector_employment()],
#'   [get_sector_wages()], [get_employment_concentration()]
#'
#' @examples
#' get_qcew_codebook()
#'
#' @export
get_qcew_codebook <- function() {

  bls_sector_fns  <- "get_sector_employment | get_sector_wages"
  cori_sector_fns <- "get_sector_employment | get_sector_wages"

  data.frame(
    stringsAsFactors = FALSE,

    variable = c(
      # Aggregate metrics
      "employment",
      "avg_pay",
      "employment_hhi",
      # Sector dimension (returned by sector functions)
      "sector",
      # Sector-level metrics
      "emp_share",
      "avg_pay"
    ),

    source_function = c(
      "get_employment | get_sector_employment",
      "get_wage_salary | get_sector_wages",
      "get_employment_concentration",
      bls_sector_fns,
      "get_sector_employment",
      "get_sector_wages"
    ),

    raw_variable = c(
      "annual_avg_emplvl",
      "annual_avg_pay",
      "hhi_emp",
      "derived",
      "{sector}_emp_share",
      "{sector}_avg_annual_pay"
    ),

    description = c(
      "Average annual employment (total covered workers, private + government)",
      "Average annual pay per worker. Nominal dollars; use cori.utils to deflate.",
      paste0(
        "Herfindahl-Hirschman Index of employment concentration across 11 BLS NAICS ",
        "super-sectors. Sum of squared employment shares scaled to 100. Higher values ",
        "indicate greater concentration (less economic diversity). Range: 0-10,000."
      ),
      paste0(
        "Sector identifier. BLS sector_type: 11 NAICS super-sectors ",
        "(e.g. 'construction', 'manufacturing'). ",
        "CORI sector_type: 3 super-sectors ",
        "('tradable_goods', 'tradable_services', 'local_services')."
      ),
      paste0(
        "Employment share of the sector as a proportion of total employment (0-1). ",
        "BLS sector_type: available for all 11 sectors. ",
        "CORI sector_type: available for all 3 super-sectors."
      ),
      paste0(
        "Employment-weighted average annual pay for the sector. Nominal dollars. ",
        "BLS sector_type: available for all 11 sectors. ",
        "CORI sector_type: available for all 3 super-sectors."
      )
    ),

    unit = c(
      "workers",
      "dollars per worker",
      "index (0-10,000)",
      "label",
      "proportion (0-1)",
      "dollars per worker"
    ),

    category = c(
      "employment",
      "wages",
      "concentration",
      "dimension",
      "employment",
      "wages"
    ),

    agg_var_description = c(
      NA,
      "Total employment (weight for employment-weighted pay averages across geographies)",
      NA,
      NA,
      "Total employment (weight for employment-weighted share aggregation)",
      "Sector employment (weight for employment-weighted pay averages across geographies)"
    )
  )
}
