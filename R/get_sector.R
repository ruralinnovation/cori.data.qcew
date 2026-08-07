#' Get Employment by Sector
#'
#' Returns employment counts or shares broken down by sector. Two sector
#' classification systems are available via the `sector_type` parameter:
#'
#' - **`"BLS"`** (default): 11 BLS NAICS super-sectors (e.g. Construction,
#'   Manufacturing, Health Care). Both employment counts and shares are available.
#' - **`"CORI"`**: 3 CORI custom super-sectors — Tradable Goods, Tradable
#'   Services, and Local Services. Only employment shares are available.
#'
#' @param geography Geographic level: `"county"` (default) or `"state"`.
#' @param geoids Character vector of FIPS codes. Use 5-digit for counties,
#'   2-digit for states. When provided, overrides `geography` for row filtering.
#' @param years Integer vector of years to return. Default `NULL` returns all
#'   available years.
#' @param sector_type Sector classification system: `"BLS"` (default) or
#'   `"CORI"`. See Details.
#' @param value_type Value to return: `"count"` (default, employment level) or
#'   `"share"` (employment share of total). Note: CORI does not support counts —
#'   if `sector_type = "CORI"` and `value_type = "count"`, shares are returned
#'   with an informational message. Multiply `value` by `agg_var` to derive
#'   approximate counts.
#'
#' @return A data frame with columns: `geoid`, `year`, `sector`, `variable`,
#'   `value`, `agg_var`. One row per geoid × year × sector combination.
#'   Variable is `employment` (count) or `emp_share` (share, 0–1).
#'   `agg_var` is total employment for shares, `NA` for counts.
#'
#' @seealso [get_employment()], [get_sector_wages()], [get_qcew_codebook()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # BLS sectors, employment counts, all counties
#'   sec <- get_sector_employment(geography = "county", years = 2018:2023)
#'
#'   # BLS employment shares
#'   sec <- get_sector_employment(geography = "state", value_type = "share")
#'
#'   # CORI super-sector shares
#'   sec <- get_sector_employment(
#'     geography   = "county",
#'     years       = 2018:2023,
#'     sector_type = "CORI",
#'     value_type  = "share"
#'   )
#' }
get_sector_employment <- function(
  geography   = "county",
  geoids      = NULL,
  years       = NULL,
  sector_type = "BLS",
  value_type  = "count"
) {

  geography   <- match.arg(geography,   c("county", "state"))
  sector_type <- match.arg(sector_type, c("BLS", "CORI"))
  value_type  <- match.arg(value_type,  c("count", "share"))

  if (sector_type == "CORI" && value_type == "count") {
    message(
      "Note: CORI super-sector employment counts are not available. ",
      "Returning employment shares instead. ",
      "To approximate counts, multiply value by agg_var."
    )
    value_type <- "share"
  }

  if (sector_type == "BLS") {
    suffix  <- if (value_type == "count") "emplvl" else "emp_share"
    vars    <- paste0(QCEW_BLS_PREFIXES, "_", suffix)
  } else {
    suffix  <- "emp_share"
    vars    <- paste0(QCEW_CORI_SECTORS, "_emp_share")
  }

  new_var  <- if (value_type == "count") "employment" else "emp_share"
  keep_agg <- value_type == "share"

  raw <- .qcew_query(
    variables = vars,
    years     = years,
    geoids    = geoids,
    geography = geography
  )

  out <- .qcew_reshape_sector(raw, suffix, new_var, keep_agg = TRUE)

  # For counts, set agg_var to NA (no meaningful weight)
  if (value_type == "count") out$agg_var <- NA_real_

  desc <- sprintf(
    "sector employment (%s, %s)",
    sector_type,
    if (value_type == "count") "count" else "share"
  )

  .qcew_message(out, .qcew_geo_label(geography, geoids), desc, .qcew_vintage_label())

  out
}


#' Get Average Pay by Sector
#'
#' Returns employment-weighted average annual pay broken down by sector. Two
#' sector classification systems are available:
#'
#' - **`"BLS"`** (default): 11 BLS NAICS super-sectors.
#' - **`"CORI"`**: 3 CORI custom super-sectors — Tradable Goods, Tradable
#'   Services, and Local Services.
#'
#' Pay values are nominal dollars. Use `cori.utils` to deflate to real terms.
#'
#' @inheritParams get_sector_employment
#'
#' @return A data frame with columns: `geoid`, `year`, `sector`, `variable`,
#'   `value`, `agg_var`. One row per geoid × year × sector combination.
#'   Variable: `avg_pay` (nominal dollars per worker).
#'   `agg_var` is sector employment — the weight for computing employment-weighted
#'   averages across geographies.
#'
#' @seealso [get_wage_salary()], [get_sector_employment()], [get_qcew_codebook()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # BLS sector wages, all counties
#'   pay <- get_sector_wages(geography = "county", years = 2018:2023)
#'
#'   # CORI super-sector wages
#'   pay <- get_sector_wages(
#'     geography   = "county",
#'     years       = 2018:2023,
#'     sector_type = "CORI"
#'   )
#'
#'   # Which sectors pay most in rural counties?
#'   pay <- get_sector_wages(geography = "county", years = 2023)
#' }
get_sector_wages <- function(
  geography   = "county",
  geoids      = NULL,
  years       = NULL,
  sector_type = "BLS"
) {

  geography   <- match.arg(geography,   c("county", "state"))
  sector_type <- match.arg(sector_type, c("BLS", "CORI"))

  sectors <- if (sector_type == "BLS") QCEW_BLS_PREFIXES else QCEW_CORI_SECTORS
  vars    <- paste0(sectors, "_avg_annual_pay")

  raw <- .qcew_query(
    variables = vars,
    years     = years,
    geoids    = geoids,
    geography = geography
  )

  out <- .qcew_reshape_sector(raw, "avg_annual_pay", "avg_pay", keep_agg = TRUE)

  desc <- sprintf("sector average pay (%s)", sector_type)
  .qcew_message(out, .qcew_geo_label(geography, geoids), desc, .qcew_vintage_label())

  out
}
