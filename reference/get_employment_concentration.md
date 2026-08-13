# Get Employment Concentration (HHI)

Returns the Herfindahl-Hirschman Index (HHI) of employment concentration
across BLS NAICS super-sectors. Higher values indicate a more
concentrated (less diversified) local economy.

## Usage

``` r
get_employment_concentration(geography = "county", geoids = NULL, years = NULL)
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
per geoid × year. Variable: `employment_hhi` (index, 0–10,000).

## Details

The index is the sum of squared employment shares (scaled to 100) across
the 11 BLS NAICS super-sectors. Values range from near 0 (perfectly
diversified) to 10,000 (single-sector economy).

## See also

[`get_sector_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_employment.md),
[`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # County-level employment concentration
  hhi <- get_employment_concentration(geography = "county", years = 2018:2023)

  # Which rural counties are most economically concentrated?
  hhi <- get_employment_concentration(geography = "county", years = 2023)
} # }
```
