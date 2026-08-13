# Maintainer Guide — cori.data.qcew

This document is for whoever is updating the package data. It covers the
annual update workflow, how to verify things worked, and common failure
modes.

------------------------------------------------------------------------

## When to update

Check `RELEASE_CALENDAR.md` for exact dates. The two moments that matter
most:

| Release | Timing | What to do |
|----|----|----|
| Q4 + Preliminary Annual | Late May / early June | Update data to include the new year |
| Final Annual | Late August / early September | Re-publish the same year’s vintage with corrected figures |

The preliminary annual (released with Q4) is good enough for most uses.
The final annual corrects late-arriving records and is typically within
1–2% of preliminary figures for most counties.

------------------------------------------------------------------------

## Pre-flight checklist

Before running anything:

Confirm the BLS file is actually available. Download and inspect the zip
manually from:
`https://data.bls.gov/cew/data/files/{year}/xls/{year}_all_county_high_level.zip`
Look for a file named `allhlcn{YY}.xlsx` (e.g. `allhlcn25.xlsx` for
2025) inside the zip. If only quarterly files (`allhlcn{YY}1.xlsx`
through `allhlcn{YY}4.xlsx`) are present, the annual file is not yet
published — wait and retry.

Confirm AWS credentials are configured (`aws sts get-caller-identity`).

Delete any stale cached files from a prior partial run (see below).

------------------------------------------------------------------------

## Step-by-step update workflow

Open R from the project root (`cori.data.qcew/`).

### 1. Clear any cached BLS files for the new year

If you (or a prior run) already downloaded the zip before the annual
file was published, the extracted folder will only contain quarterly
files. Always clear the cache before re-downloading:

``` r

year <- 2025  # <-- update this

unlink(sprintf("data/qcew/%d_qcew.zip", year))
unlink(sprintf("data/qcew/%d", year), recursive = TRUE)
```

### 2. Archive raw BLS data to S3

``` r

library(cori.data.qcew)

write_qcew_raw_to_s3(
  years     = year,
  overwrite = TRUE   # safe to use; only deletes year=YYYY/ prefix on S3
)
```

Watch for the message
`No annual file for {year} -- using allhlcn{YY}{Q}.xlsx`. If you see it,
the annual file is not in the zip — stop, clear the cache, and verify on
the BLS site before continuing.

Expected output when successful:

    Reading raw QCEW 2025...
    Downloading QCEW 2025 from BLS...
      55,724 rows written for 2025
    Raw parquet written to data/qcew/s3_raw (55,724 total rows)
    Uploading to s3://cori.data.qcew/data_raw/...

Row counts for the county high-level file are typically ~55,000–56,000.
A count well below that (e.g. ~14,000) means a quarterly file was used
instead.

### 3. Process and publish a new vintage

``` r

write_qcew_processed_to_s3(
  vintage  = as.character(year),
  years    = 1990:year,
  overwrite = TRUE
)
```

This will: 1. Run all five `pull_*` functions across all years (~5–15
minutes) 2. Write partitioned parquet locally under
`data/qcew/s3_processed/vintage_{year}/` 3. Upload to S3 and update the
`_LATEST` pointer

Expected output when successful:

    Pulling employment...
    Pulling sectoral employment shares...
    Pulling average annual pay...
    Pulling sectoral average pay...
    Pulling HHI...
    Processed parquet written: ~1,000,000+ rows to data/qcew/s3_processed/vintage_2025
    Uploading to s3://cori.data.qcew/data_processed/vintage_2025/...
    _LATEST updated to: vintage_2025

### 4. Verify

``` r

# Confirm _LATEST was updated
latest_qcew_vintage()
# Should return "vintage_2025"

# Spot-check the data
read_qcew_from_s3(
  variables = "annual_avg_emplvl",
  years     = year,
  geoids    = "00"   # national total
)
```

------------------------------------------------------------------------

## Re-publishing a final annual vintage

When BLS releases the final annual (~August), re-publish the same
vintage tag with corrected figures:

``` r

year <- 2025

unlink(sprintf("data/qcew/%d_qcew.zip", year))
unlink(sprintf("data/qcew/%d", year), recursive = TRUE)

write_qcew_raw_to_s3(years = year, overwrite = TRUE)

write_qcew_processed_to_s3(
  vintage  = as.character(year),
  years    = 1990:year,
  overwrite = TRUE   # deletes existing vintage_{year}/ on S3 before uploading
)
```

------------------------------------------------------------------------

## Common failure modes

### “No annual file for {year} – using allhlcn{YY}{Q}.xlsx”

The annual file is not in the zip. Either BLS hasn’t published it yet,
or you have a cached zip from before it was available. Clear the cache
(Step 1) and re-run. If it still happens, check the BLS URL directly.

### “data_raw/ already exists in cori.data.qcew”

The S3 upload helper refuses to overwrite an existing prefix. Fix: use
`overwrite = TRUE` in
[`write_qcew_raw_to_s3()`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_raw_to_s3.md).
If you need to upload a single year partition manually as a fallback:

``` r

system2("aws", args = c(
  "s3", "cp",
  sprintf("data/qcew/s3_raw/year=%d/", year),
  sprintf("s3://cori.data.qcew/data_raw/year=%d/", year),
  "--recursive"
))
```

### “data_processed/vintage\_{year}/ already exists in cori.data.qcew”

Same issue for the processed upload. Fix: use `overwrite = TRUE` in
[`write_qcew_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md).
The local parquet is already written so only the S3 upload needs to be
re-attempted — just re-run the function with `overwrite = TRUE`.

### Processing runs but row count looks wrong

Expected total processed rows (all years, all variables): roughly 1M+. A
significantly lower count usually means one or more years failed
silently. Check the console output from the `pull_*` functions for
skipped years.

------------------------------------------------------------------------

## S3 layout reference

    s3://cori.data.qcew/
    ├── data_raw/
    │   └── year=YYYY/
    │       └── part-0.parquet          # raw BLS wide format
    └── data_processed/
        ├── _LATEST                     # contains e.g. "vintage_2025"
        └── vintage_YYYY/
            └── year=YYYY/
                └── part-0.parquet      # CORI tidy long format

------------------------------------------------------------------------

## Local staging layout

Downloaded and processed files land in `data/qcew/` (gitignored):

    data/qcew/
    ├── {year}_qcew.zip                 # downloaded BLS zip
    ├── {year}/                         # unzipped BLS Excel files
    ├── s3_raw/
    │   └── year={year}/
    │       └── part-0.parquet
    └── s3_processed/
        └── vintage_{year}/
            └── year={year}/
                └── part-0.parquet

Safe to delete the entire `data/qcew/` directory and start fresh at any
time — nothing here is the source of truth; S3 is.
