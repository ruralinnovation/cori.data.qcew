# Pull CORI super-sector employment shares across multiple years

Returns employment share (value) and total employment weight (agg_var)
for three CORI super-sectors: tradable goods, tradable services, local
services.

## Usage

``` r
pull_sectoral_employment(years, staging_dir = "data/qcew")
```

## Arguments

- years:

  Integer vector. Years to pull.

- staging_dir:

  Character. Local staging directory. Default: `"data/qcew"`.
