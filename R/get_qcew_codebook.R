#' Get the cori.data.qcew variable codebook
#'
#' Returns documentation for all variables exposed by the public `get_*`
#' functions, including variable names, descriptions, units, and which
#' function returns each variable.
#'
#' @return A data frame with columns:
#'   - `variable`: Column name as it appears in `get_*` function output
#'   - `source_function`: Pipe-separated list of functions that return this variable
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
      # Identifiers / dimensions
      "sector",
      # employment — two raw sources
      "employment",
      "employment",
      # avg_pay — two raw sources
      "avg_pay",
      "avg_pay",
      # share and concentration
      "emp_share",
      "employment_hhi"
    ),

    source_function = c(
      bls_sector_fns,
      "get_employment",
      "get_sector_employment",
      "get_wage_salary",
      "get_sector_wages",
      "get_sector_employment",
      "get_employment_concentration"
    ),

    description = c(
      paste0(
        "Sector identifier. BLS sector_type: 11 NAICS super-sectors ",
        "(e.g. 'construction', 'manufacturing'). ",
        "CORI sector_type: 3 super-sectors ",
        "('tradable_goods', 'tradable_services', 'local_services')."
      ),
      "Total average annual employment across all industries (covered workers, private + government).",
      "Average annual employment within the sector (covered workers, private + government).",
      "Total average annual pay per worker across all industries. Nominal dollars; deflate using a BLS price index (e.g. CPI-U or ECI) to convert to real terms.",
      "Employment-weighted average annual pay within the sector. Nominal dollars; deflate using a BLS price index (e.g. CPI-U or ECI) to convert to real terms.",
      paste0(
        "Sector employment as a share of total employment (0-1). ",
        "BLS sector_type: available for all 11 sectors. ",
        "CORI sector_type: available for all 3 super-sectors."
      ),
      paste0(
        "Herfindahl-Hirschman Index of employment concentration across 11 BLS NAICS ",
        "super-sectors. Sum of squared employment shares scaled to 100. Higher values ",
        "indicate greater concentration (less economic diversity). Range: 0-10,000."
      )
    ),

    unit = c(
      "label",
      "workers",
      "workers",
      "dollars per worker",
      "dollars per worker",
      "proportion (0-1)",
      "index (0-10,000)"
    ),

    category = c(
      "dimension",
      "employment",
      "employment",
      "wages",
      "wages",
      "employment",
      "concentration"
    ),

    agg_var_description = c(
      NA,
      NA,
      NA,
      "Total employment (weight for employment-weighted pay averages across geographies)",
      "Sector employment (weight for employment-weighted pay averages across geographies)",
      "Total employment (weight for employment-weighted share aggregation)",
      NA
    )
  )
}
