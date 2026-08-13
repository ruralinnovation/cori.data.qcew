# Get Average Annual Pay Data

Returns BLS-published average annual pay per worker from the Quarterly
Census of Employment and Wages (QCEW). Values are nominal dollars —
deflate using a BLS price index (e.g. CPI-U or ECI) to convert to real
terms. Data covers 1990 to the present at the county and state level.

## Usage

``` r
get_wage_salary(geography = "county", geoids = NULL, years = NULL)
```

## Arguments

- geography:

  Geographic level: `"county"` (default) or `"state"`.

- geoids:

  Character vector of FIPS codes. Use 5-digit for counties, 2-digit for
  states. When provided, overrides `geography` for row filtering.

- years:

  Integer vector of years to return (e.g. `2018:2023`). Default `NULL`
  returns all available years.

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`. One row per geoid × year. Variable: `avg_pay` (nominal
dollars per worker). `agg_var` is total employment — the weight for
computing employment-weighted averages across geographies.

## See also

[`get_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment.md),
[`get_sector_wages()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_wages.md),
[`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # All counties
  pay <- get_wage_salary(geography = "county", years = 2015:2023)

  # Specific state
  pay <- get_wage_salary(geoids = "33", years = 2010:2023)
} # }
```
