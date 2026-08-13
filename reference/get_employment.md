# Get Total Employment Data

Returns average annual employment levels from the BLS Quarterly Census
of Employment and Wages (QCEW). Data covers 1990 to the present at the
county and state level.

## Usage

``` r
get_employment(geography = "county", geoids = NULL, years = NULL)
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

A data frame with columns: `geoid`, `year`, `variable`, `value`. One row
per geoid × year. Variable: `employment` (average annual workers).

## See also

[`get_wage_salary()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_wage_salary.md),
[`get_sector_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_employment.md),
[`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # All counties, all years
  emp <- get_employment(geography = "county")

  # Specific counties, recent years
  emp <- get_employment(geoids = c("33009", "33011"), years = 2018:2023)

  # State-level
  emp <- get_employment(geography = "state", years = 2015:2023)
} # }
```
