## Documentation/comments
### 1990 reflects the earliest release
devtools::load_all(".")

latest_year = 2025

### check vintage
s3_vintageyr <- as.numeric(substr(latest_qcew_vintage(), 9, 12))
if(latest_year <= s3_vintageyr){
  message("Latest year does not reflect a new release of data")
} else{
  stopifnot(nrow(pull_employment(latest_year, staging_dir = tempdir()))>0)
  
  ## backup raw data in s3
  write_qcew_raw_to_s3(years = latest_year)
  
  ## write new vintage
  write_qcew_processed_to_s3(
    vintage   = as.character(latest_year),
    years     = 1990:latest_year
  )
  
}
