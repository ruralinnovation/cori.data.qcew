# Write processed QCEW data to S3 as a versioned vintage

Processes all QCEW data from 1990 to the present into the CORI tidy long
format and writes a complete snapshot to S3. Each call creates a new
vintage. A `_LATEST` pointer file is also updated so
[`read_qcew_from_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/read_qcew_from_s3.md)
can find the current vintage automatically.

## Usage

``` r
write_qcew_processed_to_s3(
  vintage = NULL,
  years = 1990:as.integer(format(Sys.Date(), "%Y")),
  staging_dir = "data/qcew",
  s3_bucket = "cori.data.qcew",
  s3_path_prefix = "",
  overwrite = FALSE,
  sync_to_s3 = TRUE
)
```

## Arguments

- vintage:

  Character or `NULL`. Vintage label to use (e.g., `"2024"`). If `NULL`
  (default), derived from `max(years)`.

- years:

  Integer vector. Years to include. Default: `1990` to current year.

- staging_dir:

  Character. Local staging directory for BLS downloads. Default:
  `"data/qcew"`.

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.qcew"`.

- s3_path_prefix:

  Character. Optional prefix for all S3 keys, e.g. `"test/"` during
  development. Default: `""` (no prefix).

- overwrite:

  Logical. If `TRUE`, delete the existing S3 vintage prefix before
  uploading. Use when re-publishing the same vintage. Default: `FALSE`.

- sync_to_s3:

  Logical. Upload to S3 after writing locally. Default: `TRUE`.

## Value

Invisibly, a named list: `$vintage` and `$n_rows`.

## Details

The processed output contains one row per geoid/year/variable, with
columns `geoid`, `year`, `variable`, `value`, and `agg_var`. See
[`get_qcew_codebook`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)
for variable definitions.

## See also

[`write_qcew_raw_to_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_raw_to_s3.md),
[`read_qcew_from_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/read_qcew_from_s3.md),
[`get_qcew_codebook`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Full run -- auto-names vintage from data
write_qcew_processed_to_s3()

# Local only, scoped years
write_qcew_processed_to_s3(
  years      = 2019:2024,
  sync_to_s3 = FALSE
)

# Re-publish same vintage after adding data
write_qcew_processed_to_s3(vintage = "2024", overwrite = TRUE)
} # }
```
