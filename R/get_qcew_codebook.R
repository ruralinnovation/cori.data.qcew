#' Get the cori.data.qcew variable codebook
#'
#' Returns documentation for all variables produced by the CORI QCEW processing
#' pipeline, including variable names, labels, units, and notes.
#'
#' @return A data frame with columns: \code{variable}, \code{label},
#'   \code{unit}, \code{nominal}, \code{agg_var}, \code{notes}.
#'   \code{agg_var} describes the weighting variable returned alongside \code{value}
#'   in \code{\link{read_qcew_from_s3}}. \code{NA} means no aggregation weight
#'   is applicable for that variable.
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

  ind_prefixes <- unname(INDUSTRY_LABELS)
  ind_labels   <- c(
    "Natural resources & mining",
    "Construction",
    "Manufacturing",
    "Trade, transportation & utilities",
    "Information",
    "Financial activities",
    "Professional & business services",
    "Education & health services",
    "Leisure & hospitality",
    "Other services",
    "Public administration"
  )

  rbind(
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

      agg_var = c(
        NA,
        rep("Total employment across all industries", 3),
        "Total employment across all industries",
        rep("Sector employment (sum of employment in that super-sector)", 3),
        NA
      ),

      notes = c(
        "Annual average of monthly employment levels. Total covered (private + government).",
        paste0("Share of total employment in the CORI ", cori_labels, " super-sector."),
        "BLS-published average annual pay. Nominal dollars. Use cori.utils to deflate.",
        paste0("Employment-weighted average annual pay in the CORI ", cori_labels, " super-sector. Nominal dollars."),
        paste0(
          "Herfindahl-Hirschman Index of employment concentration across BLS NAICS super-sectors. ",
          "Sum of squared employment shares (scaled to 100). ",
          "Higher values indicate greater industry concentration."
        )
      )
    ),

    data.frame(
      stringsAsFactors = FALSE,

      variable = c(
        paste0(ind_prefixes, "_emplvl"),
        paste0(ind_prefixes, "_emp_share"),
        paste0(ind_prefixes, "_avg_annual_pay")
      ),

      label = c(
        paste(ind_labels, "employment"),
        paste(ind_labels, "employment share"),
        paste(ind_labels, "avg. annual pay")
      ),

      unit = c(
        rep("workers", 11),
        rep("proportion (0-1)", 11),
        rep("dollars per worker", 11)
      ),

      nominal = c(
        rep(FALSE, 11),
        rep(FALSE, 11),
        rep(TRUE, 11)
      ),

      agg_var = c(
        rep(NA, 11),
        rep("Total employment across all industries", 11),
        rep("Industry employment (sum of employment in that industry)", 11)
      ),

      notes = c(
        rep("Annual average employment count by BLS NAICS industry. Total covered (private + government).", 11),
        rep("Share of total employment in BLS NAICS industry.", 11),
        rep("Employment-weighted average annual pay by BLS NAICS industry. Nominal dollars.", 11)
      )
    )
  )
}
