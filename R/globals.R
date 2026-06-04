# Suppress R CMD check NOTEs for column names used in dplyr NSE pipelines.

utils::globalVariables(c(
  # Geography / identifiers
  "geoid", "year", "area_fips", "st", "cnty",

  # BLS raw column names (before janitor::clean_names())
  "NAICS", "Own", "Average Weekly Wage",

  # BLS raw column names (after janitor::clean_names())
  "annual_average_employment",
  "annual_average_pay",
  "naics", "own", "ownership",

  # NAICS quarterly fallback columns
  "january_employment",  "february_employment",  "march_employment",
  "april_employment",    "may_employment",        "june_employment",
  "july_employment",     "august_employment",     "september_employment",
  "october_employment",  "november_employment",   "december_employment",
  "average_weekly_wage",
  "qtr",

  # Industry classification
  "industry", "sector",

  # Intermediate computation
  "emp", "share", "agg_var", "weighted_wages", "prefix", "total_emp",

  # Processed output columns
  "variable", "value"
))
