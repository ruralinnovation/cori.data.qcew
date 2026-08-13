# Query QCEW data from S3 via DuckDB

Internal query engine for all `get_*()` functions. Connects to S3 using
[`cori.data.s3::connect_to_s3()`](https://rdrr.io/pkg/cori.data.s3/man/connect_to_s3.html),
builds a DuckDB query against hive-partitioned parquet files, and
returns long-format results.

## Usage

``` r
.qcew_query(
  variables = NULL,
  years = NULL,
  geoids = NULL,
  geography = NULL,
  s3_bucket = "cori.data.qcew"
)
```

## Arguments

- variables:

  Character vector. Raw variable names (e.g. "annual_avg_emplvl").

- years:

  Integer vector or `NULL`. Years to filter; `NULL` returns all.

- geoids:

  Character vector or `NULL`. FIPS codes to filter; `NULL` returns all.

- geography:

  Character. `"county"`, `"state"`, or `NULL` (both).

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.qcew"`.

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`.
