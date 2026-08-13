# Get Employment by Sector

Returns employment counts or shares broken down by sector. Two sector
classification systems are available via the `sector_type` parameter:

## Usage

``` r
get_sector_employment(
  geography = "county",
  geoids = NULL,
  years = NULL,
  sector_type = "BLS",
  value_type = "count"
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

- value_type:

  Value to return: `"count"` (default, employment level) or `"share"`
  (employment share of total). Note: CORI does not support counts — if
  `sector_type = "CORI"` and `value_type = "count"`, shares are returned
  with an informational message. Multiply `value` by `agg_var` to derive
  approximate counts.

## Value

A data frame with columns: `geoid`, `year`, `sector`, `variable`,
`value`, `agg_var`. One row per geoid × year × sector combination.
Variable is `employment` (count) or `emp_share` (share, 0–1). `agg_var`
is total employment for shares, `NA` for counts.

## Details

- **`"BLS"`** (default): 11 BLS NAICS super-sectors (e.g. Construction,
  Manufacturing, Health Care). Both employment counts and shares are
  available.

- **`"CORI"`**: 3 CORI custom super-sectors — Tradable Goods, Tradable
  Services, and Local Services. Only employment shares are available.

## See also

[`get_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment.md),
[`get_sector_wages()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_wages.md),
[`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # BLS sectors, employment counts, all counties
  sec <- get_sector_employment(geography = "county", years = 2018:2023)

  # BLS employment shares
  sec <- get_sector_employment(geography = "state", value_type = "share")

  # CORI super-sector shares
  sec <- get_sector_employment(
    geography   = "county",
    years       = 2018:2023,
    sector_type = "CORI",
    value_type  = "share"
  )
} # }
```
