# Processing functions for BLS QCEW county data.
# All functions return a data frame with columns: geoid, year, variable, value, agg_var
# agg_var is the employment weight used for downstream weighted averages (NA where not applicable).
#
# Sector definitions (CORI super-sectors):
TRADABLE_GOODS     <- c("Natural resources and mining", "Construction", "Manufacturing",
                        "Trade, transportation, and utilities")
TRADABLE_SERVICES  <- c("Information", "Financial activities", "Professional and business services")
LOCAL_SERVICES     <- c("Education and health services", "Leisure and hospitality",
                        "Other services", "Public administration")


#' Pull total employment across multiple years
#'
#' @param years Integer vector. Years to pull.
#' @param staging_dir Character. Local staging directory. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
pull_employment <- function(years, staging_dir = "data/qcew") {
  lapply(years, function(yr) {
    read_qcew_county_data(yr, staging_dir = staging_dir) |>
      dplyr::mutate(variable = "annual_avg_emplvl") |>
      dplyr::select(geoid, year, variable, value = annual_average_employment)
  }) |>
    dplyr::bind_rows()
}


#' Pull CORI super-sector employment shares across multiple years
#'
#' Returns employment share (value) and total employment weight (agg_var) for
#' three CORI super-sectors: tradable goods, tradable services, local services.
#'
#' @param years Integer vector. Years to pull.
#' @param staging_dir Character. Local staging directory. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
pull_sectoral_employment <- function(years, staging_dir = "data/qcew") {
  lapply(years, function(yr) {
    dta <- read_qcew_county_data(yr, staging_dir = staging_dir, keep_industries = TRUE)

    dta |>
      dplyr::mutate(
        industry = dplyr::if_else(
          ownership %in% c("Federal Government", "State Government", "Local Government"),
          "Public administration", industry
        ),
        sector = dplyr::case_when(
          grepl(paste(TRADABLE_GOODS,    collapse = "|"), industry) ~ "tradable_goods",
          grepl(paste(TRADABLE_SERVICES, collapse = "|"), industry) ~ "tradable_services",
          grepl(paste(LOCAL_SERVICES,    collapse = "|"), industry) ~ "local_services"
        )
      ) |>
      dplyr::filter(
        !is.na(sector),
        !grepl("Unclassified|Goods-producing|Service-providing|Total, all industries", industry)
      ) |>
      dplyr::group_by(geoid, year, variable = sector) |>
      dplyr::summarise(emp = sum(annual_average_employment, na.rm = TRUE), .groups = "drop") |>
      dplyr::group_by(geoid, year) |>
      dplyr::mutate(
        agg_var = sum(emp),
        value   = emp / agg_var,
        variable = paste0(variable, "_emp_share")
      ) |>
      dplyr::ungroup() |>
      dplyr::select(geoid, year, variable, value, agg_var)
  }) |>
    dplyr::bind_rows()
}


#' Pull average annual pay across multiple years
#'
#' @param years Integer vector. Years to pull.
#' @param staging_dir Character. Local staging directory. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
pull_annual_pay <- function(years, staging_dir = "data/qcew") {
  lapply(years, function(yr) {
    read_qcew_county_data(yr, staging_dir = staging_dir) |>
      dplyr::mutate(variable = "annual_avg_pay") |>
      dplyr::select(geoid, year, variable, value = annual_average_pay,
                    agg_var = annual_average_employment)
  }) |>
    dplyr::bind_rows()
}


#' Pull employment-weighted average annual pay by CORI super-sector
#'
#' @param years Integer vector. Years to pull.
#' @param staging_dir Character. Local staging directory. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
pull_sectoral_pay <- function(years, staging_dir = "data/qcew") {
  lapply(years, function(yr) {
    dta <- read_qcew_county_data(yr, staging_dir = staging_dir, keep_industries = TRUE)

    dta |>
      dplyr::mutate(
        industry = dplyr::if_else(
          ownership %in% c("Federal Government", "State Government", "Local Government"),
          "Public administration", industry
        ),
        sector = dplyr::case_when(
          grepl(paste(TRADABLE_GOODS,    collapse = "|"), industry) ~ "tradable_goods",
          grepl(paste(TRADABLE_SERVICES, collapse = "|"), industry) ~ "tradable_services",
          grepl(paste(LOCAL_SERVICES,    collapse = "|"), industry) ~ "local_services"
        )
      ) |>
      dplyr::filter(
        !is.na(sector),
        !grepl("Unclassified|Goods-producing|Service-providing|Total, all industries", industry)
      ) |>
      dplyr::group_by(geoid, year, sector) |>
      dplyr::summarise(
        agg_var        = sum(annual_average_employment, na.rm = TRUE),
        weighted_wages = sum(annual_average_pay * annual_average_employment, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::mutate(
        value    = weighted_wages / agg_var,
        variable = paste0(sector, "_avg_annual_pay")
      ) |>
      dplyr::select(geoid, year, variable, value, agg_var)
  }) |>
    dplyr::bind_rows()
}


#' Pull Herfindahl-Hirschman Index of employment concentration
#'
#' @param years Integer vector. Years to pull.
#' @param staging_dir Character. Local staging directory. Default: \code{"data/qcew"}.
#'
#' @keywords internal
#' @export
pull_hhi <- function(years, staging_dir = "data/qcew") {
  lapply(years, function(yr) {
    dta <- read_qcew_county_data(yr, staging_dir = staging_dir, keep_industries = TRUE)

    dta |>
      dplyr::mutate(
        industry = dplyr::if_else(
          ownership %in% c("Federal Government", "State Government", "Local Government"),
          "Public administration", industry
        )
      ) |>
      dplyr::filter(
        !grepl("Goods-producing|Service-providing|Total, all industries", industry)
      ) |>
      dplyr::group_by(geoid, year, industry) |>
      dplyr::summarise(emp = sum(annual_average_employment, na.rm = TRUE), .groups = "drop") |>
      dplyr::group_by(geoid, year) |>
      dplyr::mutate(share = emp / sum(emp)) |>
      dplyr::summarise(
        variable = "hhi_emp",
        value    = sum((share * 100) ^ 2),
        .groups  = "drop"
      )
  }) |>
    dplyr::bind_rows()
}


