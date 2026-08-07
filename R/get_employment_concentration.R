#' Get Employment Concentration (HHI)
#'
#' Returns the Herfindahl-Hirschman Index (HHI) of employment concentration
#' across BLS NAICS super-sectors. Higher values indicate a more concentrated
#' (less diversified) local economy.
#'
#' The index is the sum of squared employment shares (scaled to 100) across
#' the 11 BLS NAICS super-sectors. Values range from near 0 (perfectly
#' diversified) to 10,000 (single-sector economy).
#'
#' @inheritParams get_employment
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`.
#'   One row per geoid × year. Variable: `employment_hhi` (index, 0–10,000).
#'
#' @seealso [get_sector_employment()], [get_qcew_codebook()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # County-level employment concentration
#'   hhi <- get_employment_concentration(geography = "county", years = 2018:2023)
#'
#'   # Which rural counties are most economically concentrated?
#'   hhi <- get_employment_concentration(geography = "county", years = 2023)
#' }
get_employment_concentration <- function(geography = "county", geoids = NULL, years = NULL) {

  geography <- match.arg(geography, c("county", "state"))

  raw <- .qcew_query(
    variables = "hhi_emp",
    years     = years,
    geoids    = geoids,
    geography = geography
  )

  raw$variable <- "employment_hhi"
  out <- raw[, c("geoid", "year", "variable", "value"), drop = FALSE]

  .qcew_message(
    out,
    .qcew_geo_label(geography, geoids),
    "employment concentration (HHI)",
    .qcew_vintage_label()
  )

  out
}
