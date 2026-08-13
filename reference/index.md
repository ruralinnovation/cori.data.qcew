# Package index

## Employment and Wages

- [`get_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment.md)
  : Get Total Employment Data
- [`get_wage_salary()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_wage_salary.md)
  : Get Average Annual Pay Data
- [`get_sector_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_employment.md)
  : Get Employment by Sector
- [`get_sector_wages()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_sector_wages.md)
  : Get Average Pay by Sector
- [`get_employment_concentration()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_employment_concentration.md)
  : Get Employment Concentration (HHI)

## Utilities

- [`get_qcew_codebook()`](https://ruralinnovation.github.io/cori.data.qcew/reference/get_qcew_codebook.md)
  : Get the cori.data.qcew variable codebook
- [`latest_qcew_vintage()`](https://ruralinnovation.github.io/cori.data.qcew/reference/latest_qcew_vintage.md)
  : Return the current latest QCEW vintage name from S3
- [`read_qcew_from_s3()`](https://ruralinnovation.github.io/cori.data.qcew/reference/read_qcew_from_s3.md)
  : Read processed QCEW data from S3

## Internal

Functions for data processing and maintenance

- [`download_qcew()`](https://ruralinnovation.github.io/cori.data.qcew/reference/download_qcew.md)
  : Download BLS QCEW county high-level zip file for a single year
- [`pull_annual_pay()`](https://ruralinnovation.github.io/cori.data.qcew/reference/pull_annual_pay.md)
  : Pull average annual pay across multiple years
- [`pull_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/pull_employment.md)
  : Pull total employment across multiple years
- [`pull_hhi()`](https://ruralinnovation.github.io/cori.data.qcew/reference/pull_hhi.md)
  : Pull Herfindahl-Hirschman Index of employment concentration
- [`pull_sectoral_employment()`](https://ruralinnovation.github.io/cori.data.qcew/reference/pull_sectoral_employment.md)
  : Pull CORI super-sector employment shares across multiple years
- [`pull_sectoral_pay()`](https://ruralinnovation.github.io/cori.data.qcew/reference/pull_sectoral_pay.md)
  : Pull employment-weighted average annual pay by CORI super-sector
- [`read_qcew_county_data()`](https://ruralinnovation.github.io/cori.data.qcew/reference/read_qcew_county_data.md)
  : Read raw BLS QCEW county data for a single year
- [`write_qcew_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md)
  : Write processed QCEW data to S3 as a versioned vintage
- [`write_qcew_raw_to_s3()`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_raw_to_s3.md)
  : Write raw QCEW data to S3 as partitioned parquet
