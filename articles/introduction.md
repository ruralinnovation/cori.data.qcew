# Introduction to cori.data.qcew

## What is this data?

The Bureau of Labor Statistics Quarterly Census of Employment and Wages
(QCEW) covers virtually all U.S. jobs — roughly 95% of all employment —
through the unemployment insurance system. Unlike surveys, QCEW is a
near-census of covered employment and wages, making it the gold standard
for local labor market analysis.

Data is available at the **county and state level** from **1990 to the
present**.

## Quick start

``` r

library(cori.data.qcew)
```

``` r

# See all available variables and which functions return them
get_qcew_codebook()
```

All `get_*` functions return **tidy (long) format**:
`geoid | year | variable | value`, with `agg_var` included where the
variable is a rate or share (to support employment-weighted aggregation
across geographies).

``` r

# Total employment — county level
emp <- get_employment(geography = "county", years = 2018:2023)

# Average annual pay — county level
pay <- get_wage_salary(geography = "county", years = 2018:2023)

# Employment concentration (HHI)
hhi <- get_employment_concentration(geography = "county", years = 2018:2023)
```

## Sector breakdowns

Two sector classification systems are available via `sector_type`:

- **`"BLS"`** (default) — 11 NAICS super-sectors from the source data
- **`"CORI"`** — 3 custom super-sectors: Tradable Goods, Tradable
  Services, and Local Services

``` r

# BLS sector employment counts
bls_emp <- get_sector_employment(
  geography   = "county",
  years       = 2018:2023,
  sector_type = "BLS",
  value_type  = "count"
)

# BLS sector employment shares
bls_share <- get_sector_employment(
  geography   = "county",
  years       = 2018:2023,
  sector_type = "BLS",
  value_type  = "share"
)

# CORI super-sector employment shares
cori_share <- get_sector_employment(
  geography   = "county",
  years       = 2018:2023,
  sector_type = "CORI",
  value_type  = "share"
)
```

``` r

# Average pay by BLS sector
bls_pay <- get_sector_wages(geography = "county", years = 2018:2023)

# Average pay by CORI super-sector
cori_pay <- get_sector_wages(
  geography   = "county",
  years       = 2018:2023,
  sector_type = "CORI"
)
```

**Note on CORI counts:** CORI super-sector employment counts are not
stored directly. To derive approximate counts from shares, multiply
`value` by `agg_var`:

``` r

library(dplyr)

cori_share |>
  mutate(approx_employment = value * agg_var)
```

## Filtering by geography

``` r

# Specific counties
emp <- get_employment(geoids = c("33009", "33011"), years = 2010:2023)

# Specific states
pay <- get_wage_salary(geoids = c("33", "50", "23"), years = 2015:2023)
```

## Rural vs. non-rural comparison

``` r

library(dplyr)

# Pull county-level employment
county_emp <- get_employment(geography = "county", years = 2010:2023)

# Join your rural definition and compare
# (rural_geoids would come from cori.data or ruraldefinitions package)
county_emp |>
  mutate(rural = geoid %in% rural_geoids) |>
  group_by(year, rural) |>
  summarize(total_employment = sum(value, na.rm = TRUE), .groups = "drop")
```

## Understanding agg_var

Functions that return rates or shares include an `agg_var` column — the
employment weight used for proper aggregation across geographies. For
example, to compute a population-weighted average pay across a set of
counties:

``` r

pay <- get_wage_salary(geography = "county", years = 2023)

# Employment-weighted average pay across all counties
pay |>
  summarize(
    weighted_avg_pay = sum(value * agg_var, na.rm = TRUE) /
                       sum(agg_var, na.rm = TRUE)
  )
```
