# Get Average Pay by Sector

Returns employment-weighted average annual pay broken down by sector.
Two sector classification systems are available:

## Usage

``` r
get_sector_wages(
  geography = "county",
  geoids = NULL,
  years = NULL,
  sector_type = "BLS"
)
```

## Arguments

- geography:

  Geographic level: `"county"` (default) or `"state"`.

- geoids:

  Character vector of FIPS codes. Use 5-digit for counties, 2-digit for
  states. When provided, overrides `geography` for row filtering.

- years:

  Integer vector of years to return. Default `NULL` returns all
  available years.

- sector_type:

  Sector classification system: `"BLS"` (default) or `"CORI"`. See
  Details.

## Value

A data frame with columns: `geoid`, `year`, `sector`, `variable`,
`value`, `agg_var`. One row per geoid × year × sector combination.
Variable: `avg_pay` (nominal dollars per worker). `agg_var` is sector
employment — the weight for computing employment-weighted averages
across geographies.

## Details

- **`"BLS"`** (default): 11 BLS NAICS super-sectors.

- **`"CORI"`**: 3 CORI custom super-sectors — Tradable Goods, Tradable
  Services, and Local Services.

Pay values are nominal dollars. Deflate using a BLS price index (e.g.
CPI-U or ECI) to convert to real terms.

## See also

[`get_wage_salary()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_wage_salary.md),
[`get_sector_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_employment.md),
[`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # BLS sector wages, all counties
  pay <- get_sector_wages(geography = "county", years = 2018:2023)

  # CORI super-sector wages
  pay <- get_sector_wages(
    geography   = "county",
    years       = 2018:2023,
    sector_type = "CORI"
  )

  # Which sectors pay most in rural counties?
  pay <- get_sector_wages(geography = "county", years = 2023)
} # }
```
