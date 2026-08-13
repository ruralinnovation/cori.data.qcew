# Get the cori.data.qcew variable codebook

Returns documentation for all variables exposed by the public `get_*`
functions, including variable names, descriptions, units, and which
function returns each variable.

## Usage

``` r
get_qcew_codebook()
```

## Value

A data frame with columns:

- `variable`: Column name as it appears in `get_*` function output

- `source_function`: Pipe-separated list of functions that return this
  variable

- `description`: Plain-language description

- `unit`: Unit of measurement

- `category`: Variable category

- `agg_var_description`: What `agg_var` represents for this variable
  (`NA` if `agg_var` is not returned by the source function)

## Details

All `get_*` functions return tidy (long) format. The `variable` column
identifies the metric; `value` holds the numeric result. Sector
functions add a `sector` dimension column. Where `agg_var` is returned,
it carries the employment weight used for computing employment-weighted
averages across geographies.

## See also

[`get_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment.md),
[`get_wage_salary()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_wage_salary.md),
[`get_sector_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_employment.md),
[`get_sector_wages()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_wages.md),
[`get_employment_concentration()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment_concentration.md)

## Examples

``` r
get_qcew_codebook()
#>         variable                          source_function
#> 1         sector get_sector_employment | get_sector_wages
#> 2     employment                           get_employment
#> 3     employment                    get_sector_employment
#> 4        avg_pay                          get_wage_salary
#> 5        avg_pay                         get_sector_wages
#> 6      emp_share                    get_sector_employment
#> 7 employment_hhi             get_employment_concentration
#>                                                                                                                                                                                                                          description
#> 1                                    Sector identifier. BLS sector_type: 11 NAICS super-sectors (e.g. 'construction', 'manufacturing'). CORI sector_type: 3 super-sectors ('tradable_goods', 'tradable_services', 'local_services').
#> 2                                                                                                                                     Total average annual employment across all industries (covered workers, private + government).
#> 3                                                                                                                                               Average annual employment within the sector (covered workers, private + government).
#> 4                                                                          Total average annual pay per worker across all industries. Nominal dollars; deflate using a BLS price index (e.g. CPI-U or ECI) to convert to real terms.
#> 5                                                                           Employment-weighted average annual pay within the sector. Nominal dollars; deflate using a BLS price index (e.g. CPI-U or ECI) to convert to real terms.
#> 6                                                                        Sector employment as a share of total employment (0-1). BLS sector_type: available for all 11 sectors. CORI sector_type: available for all 3 super-sectors.
#> 7 Herfindahl-Hirschman Index of employment concentration across 11 BLS NAICS super-sectors. Sum of squared employment shares scaled to 100. Higher values indicate greater concentration (less economic diversity). Range: 0-10,000.
#>                 unit      category
#> 1              label     dimension
#> 2            workers    employment
#> 3            workers    employment
#> 4 dollars per worker         wages
#> 5 dollars per worker         wages
#> 6   proportion (0-1)    employment
#> 7   index (0-10,000) concentration
#>                                                                  agg_var_description
#> 1                                                                               <NA>
#> 2                                                                               <NA>
#> 3                                                                               <NA>
#> 4  Total employment (weight for employment-weighted pay averages across geographies)
#> 5 Sector employment (weight for employment-weighted pay averages across geographies)
#> 6                Total employment (weight for employment-weighted share aggregation)
#> 7                                                                               <NA>
```
