# Read processed QCEW data from S3

Queries the CORI tidy QCEW parquet files from S3 using DuckDB with the
httpfs extension. Returns long-format data — one row per
geoid/year/variable.

## Usage

``` r
read_qcew_from_s3(
  vintage = "latest",
  variables = NULL,
  years = NULL,
  geoids = NULL,
  s3_bucket = "cori.data.qcew",
  s3_path_prefix = ""
)
```

## Arguments

- vintage:

  Character. The vintage to read — e.g., `"2024"`. Default: `"latest"`,
  which reads the `_LATEST` pointer written by
  [`write_qcew_processed_to_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md).

- variables:

  Character vector. Variable names to return. Default: `NULL` (all
  variables). See
  [`get_qcew_codebook`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md).

- years:

  Integer vector. Years to return. Default: `NULL` (all years).

- geoids:

  Character vector. FIPS codes to filter to. Accepts 5-digit county,
  2-digit state, or `"00"` for national. Default: `NULL` (all
  geographies).

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.qcew"`.

- s3_path_prefix:

  Character. Optional prefix matching the one used in
  [`write_qcew_processed_to_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md),
  e.g. `"test/"` for dev uploads. Default: `""` (no prefix).

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`,
`agg_var`.

## See also

[`latest_qcew_vintage`](https://ruralinnovation.github.io/cori.data.qcew/reference/latest_qcew_vintage.md),
[`get_qcew_codebook`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# All data, latest vintage
df <- read_qcew_from_s3()

# Specific variable and years
df <- read_qcew_from_s3(
  variables = "annual_avg_emplvl",
  years     = 2007:2024
)

# Specific counties
df <- read_qcew_from_s3(
  geoids = c("54011", "54025"),
  years  = 2010:2023
)
} # }
```
