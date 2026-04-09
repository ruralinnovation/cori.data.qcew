#' Get the cori.data.qcew variable codebook
#'
#' Returns documentation for all variables produced by the CORI QCEW processing
#' pipeline, including variable names, labels, units, and notes.
#'
#' @return A data frame with columns: \code{variable}, \code{label},
#'   \code{unit}, \code{nominal}, \code{notes}.
#'
#' @seealso \code{\link{read_qcew_from_s3}}
#'
#' @examples
#' cb <- get_qcew_codebook()
#' cb
#'
#' @export
get_qcew_codebook <- function() {

  cori_sectors <- c("tradable_goods", "tradable_services", "local_services")
  cori_labels  <- c("Tradable goods", "Tradable services", "Local services")

  data.frame(
    stringsAsFactors = FALSE,

    variable = c(
      "annual_avg_emplvl",
      paste0(cori_sectors, "_emp_share"),
      "annual_avg_pay",
      paste0(cori_sectors, "_avg_annual_pay"),
      "hhi_emp"
    ),

    label = c(
      "Average annual employment",
      paste(cori_labels, "employment share"),
      "Average annual pay",
      paste(cori_labels, "avg. annual pay"),
      "Employment HHI"
    ),

    unit = c(
      "workers",
      rep("proportion (0-1)", 3),
      "dollars per worker",
      rep("dollars per worker", 3),
      "index (0-10,000)"
    ),

    nominal = c(
      FALSE,
      FALSE, FALSE, FALSE,
      TRUE,
      TRUE, TRUE, TRUE,
      FALSE
    ),

    notes = c(
      "Annual average of monthly employment levels. Total covered (private + government).",

      paste0("Share of total employment in the CORI ", cori_labels, " super-sector. ",
             "agg_var = total employment (denominator)."),

      "BLS-published average annual pay. Nominal dollars. Use cori.utils to deflate.",

      paste0("Employment-weighted average annual pay in the CORI ", cori_labels,
             " super-sector. agg_var = sector employment. Nominal dollars."),

      paste0(
        "Herfindahl-Hirschman Index of employment concentration across BLS NAICS super-sectors. ",
        "Sum of squared employment shares (scaled to 100). ",
        "Higher values indicate greater industry concentration."
      )
    )
  )
}
