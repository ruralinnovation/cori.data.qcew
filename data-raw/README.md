## Updating the data

Run these when BLS publishes new annual data:

```r
# 1. Backup the new year's raw BLS file to S3
write_qcew_raw_to_s3(years = <new_year>, overwrite = TRUE)

# 2. Reprocess all years and publish a new vintage
write_qcew_processed_to_s3(
  vintage   = as.character(<new_year>),
  years     = 1990:<new_year>,
  overwrite = TRUE
)
```