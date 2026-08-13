# Write raw QCEW data to S3 as partitioned parquet

Downloads BLS QCEW county high-level files for each year, reads the raw
BLS column structure (wide format), and writes year-partitioned parquet
files to S3. This is the archival mirror of BLS source files.

## Usage

``` r
write_qcew_raw_to_s3(
  years = 1990:as.integer(format(Sys.Date(), "%Y")),
  staging_dir = "data/qcew",
  s3_bucket = "cori.data.qcew",
  overwrite = FALSE,
  sync_to_s3 = TRUE
)
```

## Arguments

- years:

  Integer vector. Years to pull. Default: `1990` to current year.

- staging_dir:

  Character. Local directory for staging downloads. Default:
  `"data/qcew"`.

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.qcew"`.

- overwrite:

  Logical. If `TRUE`, delete existing S3 year partitions before
  uploading. Use when re-publishing years already on S3. Default:
  `FALSE`.

- sync_to_s3:

  Logical. Upload to S3 after writing locally. Default: `TRUE`.

## Value

Invisibly, total row count written.

## Details

Intended to be run by the package maintainer when new data is available.

## See also

[`write_qcew_processed_to_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Full run
write_qcew_raw_to_s3()

# Specific years, local only
write_qcew_raw_to_s3(years = 2022:2024, sync_to_s3 = FALSE)

# Add a new year when data_raw/ already exists in S3
write_qcew_raw_to_s3(years = 2025, overwrite = TRUE)
} # }
```
