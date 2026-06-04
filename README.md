# cori.data.qcew

An R package for accessing and analyzing Bureau of Labor Statistics [Quarterly Census of Employment and Wages (QCEW)](https://www.bls.gov/cew/) data at the county, state, and national level.

## Installation

```r
# install.packages("devtools")
devtools::install_github("ruralinnovation/cori.data.qcew")
```

## Quick start

```r
library(cori.data.qcew)

# See what variables are available
get_qcew_codebook()

# Read the latest processed data from S3
df <- read_qcew_from_s3(
  variables = "annual_avg_emplvl",
  years     = 2010:as.integer(gsub("vintage_", "", latest_qcew_vintage()))
)
```

`read_qcew_from_s3()` queries pre-processed parquet files on S3 using DuckDB — no large downloads required. AWS credentials must be configured.

## Available variables

| Variable | Description | Unit |
|---|---|---|
| `annual_avg_emplvl` | Average annual employment | workers |
| `annual_avg_pay` | Average annual pay (nominal) | dollars/worker |
| `tradable_goods_emp_share` | Tradable goods employment share | proportion (0–1) |
| `tradable_services_emp_share` | Tradable services employment share | proportion (0–1) |
| `local_services_emp_share` | Local services employment share | proportion (0–1) |
| `tradable_goods_avg_annual_pay` | Tradable goods avg. annual pay | dollars/worker |
| `tradable_services_avg_annual_pay` | Tradable services avg. annual pay | dollars/worker |
| `local_services_avg_annual_pay` | Local services avg. annual pay | dollars/worker |
| `hhi_emp` | Employment Herfindahl-Hirschman Index | index (0–10,000) |

See `get_qcew_codebook()` for full definitions including notes on nominal values and aggregation weights.

## Filtering

```r
# County-level employment for specific states
read_qcew_from_s3(
  variables = "annual_avg_emplvl",
  geoids    = c("23001", "23003", "23005")   # 5-digit FIPS = county
)

# State-level pay
read_qcew_from_s3(
  variables = "annual_avg_pay",
  geoids    = c("23", "50", "33")            # 2-digit FIPS = state
)

# National totals only
read_qcew_from_s3(geoids = "00")             # "00" = national
```

## Vintages

Each processed snapshot is tagged with a vintage (e.g., `"vintage_2025"`). The `_LATEST` pointer on S3 always resolves to the most recent vintage.

```r
# Check current vintage
latest_qcew_vintage()

# Read a specific vintage
read_qcew_from_s3(vintage = "2024")
```

## Updating the data

Run these when BLS publishes new data (see `RELEASE_CALENDAR.md` for timing):

```r
# 1. Archive the new year's raw BLS file to S3
write_qcew_raw_to_s3(years = <new_year>, overwrite = TRUE)

# 2. Reprocess all years and publish a new vintage
write_qcew_processed_to_s3(
  vintage  = as.character(<new_year>),
  years    = 1990:<new_year>,
  overwrite = TRUE
)
```

The `_LATEST` pointer is updated automatically so all users get the new data on their next call to `read_qcew_from_s3()`.

## Vignettes

- **Rural vs. Nonrural Employment Trends** — county employment trends since the Great Recession, broken down by rural status and Census region
