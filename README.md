---
editor_options: 
  markdown: 
    wrap: 72
---

# cori.data.qcew

An R package for accessing and analyzing Bureau of Labor Statistics
[Quarterly Census of Employment and Wages
(QCEW)](https://www.bls.gov/cew/) data at the county and state level.
Data covers 1990 to the present.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("ruralinnovation/cori.data.qcew")
```

## Quick start

``` r
library(cori.data.qcew)

# See all available variables and which functions return them
get_qcew_codebook()

# Total employment — all counties, all years
get_employment(geography = "county")

# Average annual pay — specific counties
get_wage_salary(geoids = c("33009", "33011"), years = 2010:2023)

# Employment by BLS supersector
get_sector_employment(geography = "county", years = 2018:2023,
                      sector_type = "BLS", value_type = "share")

# Employment concentration (HHI)
get_employment_concentration(geography = "county", years = 2023)
```

------------------------------------------------------------------------

## Functions

| Function | Returns | Key parameters |
|------------------------|------------------------|------------------------|
| `get_employment()` | Total average annual employment | `geography`, `geoids`, `years` |
| `get_wage_salary()` | Total average annual pay | `geography`, `geoids`, `years` |
| `get_sector_employment()` | Employment by sector | \+ `sector_type`, `value_type` |
| `get_sector_wages()` | Average pay by sector | \+ `sector_type` |
| `get_employment_concentration()` | Employment HHI | `geography`, `geoids`, `years` |

All functions return tidy (long) format:
`geoid | year | sector | variable | value`. Rate and share variables
include an `agg_var` column (employment weight for computing weighted
averages across geographies).

------------------------------------------------------------------------

## Sector classifications

QCEW sector data is available under two classification systems,
controlled by the `sector_type` parameter in `get_sector_employment()`
and `get_sector_wages()`.

### BLS supersectors (`sector_type = "BLS"`)

The default classification follows the BLS QCEW supersector groupings —
11 aggregations of 2-digit NAICS industries. These are the source-level
groupings published by BLS.

See the full BLS definition: [BLS QCEW Industry
Supersectors](https://www.bls.gov/cew/classifications/industry/industry-supersectors.htm)

| Sector (variable prefix) | BLS Supersector | NAICS codes |
|------------------------|------------------------|------------------------|
| `natural_resources_mining` | Natural Resources and Mining | 11, 21 |
| `construction` | Construction | 23 |
| `manufacturing` | Manufacturing | 31–33 |
| `trade_transportation_utilities` | Trade, Transportation, and Utilities | 22, 42, 44–45, 48–49 |
| `information` | Information | 51 |
| `financial_activities` | Financial Activities | 52–53 |
| `professional_business_services` | Professional and Business Services | 54–56 |
| `education_health_services` | Education and Health Services | 61–62 |
| `leisure_hospitality` | Leisure and Hospitality | 71–72 |
| `other_services` | Other Services | 81 |
| `public_administration` | Public Administration | 92 |

**Note on Public Administration:** BLS publishes government employment
under ownership codes (Federal, State, Local Government) rather than as
a NAICS industry. CORI derives public administration employment by
summing rows where ownership is Federal, State, or Local Government.

### CORI supersectors (`sector_type = "CORI"`)

CORI aggregates the 11 BLS supersectors into 3 custom supersectors based
on whether an industry primarily serves **tradable**
(national/international) or **local** demand. This classification is
loosely derived from the methodology in Eckert (2018), Appendix H1.

> Eckert, F. (2018). *Growing Apart: Tradable Services and the
> Fragmentation of the US Economy*. Job Market Paper, University of
> Notre Dame.
> [PDF](https://economics.nd.edu/assets/303413/eckert_jmp_2018.pdf)

| CORI Supersector | Constituent BLS supersectors | Rationale |
|------------------------|------------------------|------------------------|
| **Tradable Goods** | Natural Resources & Mining, Construction, Manufacturing, Trade, Transportation & Utilities | Industries producing or moving physical goods that cross geographic boundaries and face national or international competition |
| **Tradable Services** | Information, Financial Activities, Professional & Business Services | Knowledge-intensive service industries whose output can be delivered remotely and whose markets extend beyond the local area |
| **Local Services** | Education & Health Services, Leisure & Hospitality, Other Services, Public Administration | Industries primarily serving local demand — residents and institutions within the geography |

**Important limitations:**

-   CORI supersectors are available as **employment shares only** — not
    counts. To approximate sector employment counts, multiply `value`
    (share) by `agg_var` (total employment).
-   The CORI classification is an opinionated aggregation. Use
    `sector_type = "BLS"` when you need the source-level groupings or
    want to construct your own aggregations.

------------------------------------------------------------------------

## Geography

Data is available at two levels:

| `geography` | `geoid` format | Coverage              |
|-------------|----------------|-----------------------|
| `"county"`  | 5-digit FIPS   | \~3,100 U.S. counties |
| `"state"`   | 2-digit FIPS   | 50 states + DC        |

Use the `geoids` parameter to filter to specific counties or states:

``` r
# Specific counties (5-digit FIPS)
get_employment(geoids = c("33009", "33011"), years = 2010:2023)

# Specific states (2-digit FIPS)
get_wage_salary(geoids = c("33", "50", "23"), years = 2015:2023)
```

------------------------------------------------------------------------

## Variables

| Variable | Function | Unit | `agg_var` |
|------------------|------------------|------------------|------------------|
| `employment` | `get_employment`, `get_sector_employment` | workers | — |
| `avg_pay` | `get_wage_salary`, `get_sector_wages` | nominal \$/worker | total employment (wages) or sector employment (sector wages) |
| `emp_share` | `get_sector_employment` | proportion (0–1) | total employment |
| `employment_hhi` | `get_employment_concentration` | index (0–10,000) | — |

Pay values are **nominal dollars**. To convert to real dollars, deflate
using a BLS price index such as the [Consumer Price Index
(CPI-U)](https://www.bls.gov/cpi/) or the [Employment Cost Index
(ECI)](https://www.bls.gov/eci/).

------------------------------------------------------------------------

## Vintages

Each processed snapshot is tagged with a vintage (e.g.,
`"vintage_2025"`). The `_LATEST` pointer on S3 always resolves to the
most recent vintage.

``` r
# Check current vintage
latest_qcew_vintage()
```

The `_LATEST` pointer updates automatically so all users get new data on
their next function call.
