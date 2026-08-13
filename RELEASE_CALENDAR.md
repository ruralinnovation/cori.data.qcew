# cori.data.qcew — Release Calendar

Source: <https://www.bls.gov/cew/release-calendar.htm> Last reviewed:
April 2026

------------------------------------------------------------------------

## Typical Release Cadence

BLS publishes QCEW data quarterly. Starting with Q4 2024 data (released
June 4, 2025), the County Employment and Wages news release and the full
data update are published on the same date. Prior to that, the full data
update lagged the news release by ~2 weeks.

| Data Period | Typical Full Data Release | Notes |
|----|----|----|
| Q1 (Jan–Mar) | Late August of same year | e.g. Q1 2025 → Sep 9, 2025 |
| Q2 (Apr–Jun) | Late November / early December | e.g. Q2 2025 → Dec 19, 2025 |
| Q3 (Jul–Sep) | Late February / early March of following year | e.g. Q3 2025 → Mar 10, 2026 |
| Q4 (Oct–Dec) + Preliminary Annual | Late May / early June of following year | e.g. Q4 2025 → Jun 2, 2026 |
| **Final Annual** | Released with Q1 data of the following year (~August) | e.g. Final 2025 annual → ~Aug 2026 |

**Key distinction:** Preliminary annual averages are published with Q4
data (~June). Final annual averages are published with Q1 data of the
following year (~August/September). The `latest_qcew_year()` function
defaults to the most recent **final** annual vintage.

------------------------------------------------------------------------

## `latest_qcew_year()` Logic

``` r

# Final annual data for year Y is released with Q1 data for year Y+1, typically in August.
# If current month >= 9 (September or later), final data for current_year - 1 is available.
# Otherwise, final data for current_year - 2 is the latest safe bet.
if (current_month >= 9) current_year - 1L else current_year - 2L
```

To access preliminary annual data (available ~June with Q4 release), use
`latest_qcew_year(preliminary = TRUE)`:

``` r

# Preliminary annual for year Y is released with Q4 data, typically in June.
if (current_month >= 6) current_year - 1L else current_year - 2L
```

------------------------------------------------------------------------

## Actual Release Dates (2019–2026)

### 2026

| Reference Quarter | Full Data Release       | Notes |
|-------------------|-------------------------|-------|
| Q1 2026           | Friday, Aug. 28, 2026   |       |
| Q2 2026           | Wednesday, Dec. 2, 2026 |       |
| Q3 2026           | TBD 2027                |       |
| Q4 2026           | TBD 2027                |       |

### 2025

| Reference Quarter | Full Data Release | Notes |
|----|----|----|
| Q1 2025 | Tuesday, Sep. 9, 2025 |  |
| Q2 2025 | Friday, Dec. 19, 2025 | Delayed — 2025 lapse in appropriations |
| Q3 2025 | Tuesday, Mar. 10, 2026 |  |
| Q4 2025 + Preliminary Annual | Tuesday, Jun. 2, 2026 |  |

### 2024

| Reference Quarter | Full Data Release | Notes |
|----|----|----|
| Q1 2024 | Wednesday, Sep. 4, 2024 |  |
| Q2 2024 | Thursday, Dec. 5, 2024 |  |
| Q3 2024 | Wednesday, Mar. 5, 2025 |  |
| Q4 2024 + Preliminary Annual | Wednesday, Jun. 4, 2025 | First release where news release = full data release |

### 2023

| Reference Quarter            | Full Data Release       |
|------------------------------|-------------------------|
| Q1 2023                      | Wednesday, Sep. 6, 2023 |
| Q2 2023                      | Thursday, Dec. 7, 2023  |
| Q3 2023                      | Wednesday, Mar. 6, 2024 |
| Q4 2023 + Preliminary Annual | Wednesday, Jun. 5, 2024 |

### 2022

| Reference Quarter            | Full Data Release       |
|------------------------------|-------------------------|
| Q1 2022                      | Wednesday, Sep. 7, 2022 |
| Q2 2022                      | Tuesday, Dec. 6, 2022   |
| Q3 2022                      | Wednesday, Mar. 8, 2023 |
| Q4 2022 + Preliminary Annual | Wednesday, Jun. 7, 2023 |

### 2021

| Reference Quarter            | Full Data Release       |
|------------------------------|-------------------------|
| Q1 2021                      | Wednesday, Sep. 1, 2021 |
| Q2 2021                      | Wednesday, Dec. 1, 2021 |
| Q3 2021                      | Wednesday, Mar. 9, 2022 |
| Q4 2021 + Preliminary Annual | Wednesday, Jun. 8, 2022 |

### 2020

| Reference Quarter            | Full Data Release       |
|------------------------------|-------------------------|
| Q1 2020                      | Wednesday, Sep. 2, 2020 |
| Q2 2020                      | Wednesday, Dec. 2, 2020 |
| Q3 2020                      | Tuesday, Mar. 9, 2021   |
| Q4 2020 + Preliminary Annual | Wednesday, Jun. 2, 2021 |

### 2019

| Reference Quarter            | Full Data Release       |
|------------------------------|-------------------------|
| Q1 2019                      | Wednesday, Sep. 4, 2019 |
| Q2 2019                      | Wednesday, Dec. 4, 2019 |
| Q3 2019                      | Wednesday, Mar. 4, 2020 |
| Q4 2019 + Preliminary Annual | Wednesday, Jun. 3, 2020 |

------------------------------------------------------------------------

## SIC Historical Data

The SIC era (1975–1989) is static — no new releases. These files are
permanently archived at BLS and available at:
`https://data.bls.gov/cew/data/files/{year}/sic/csv/sic_{year}_qtrly_by_area.zip`

------------------------------------------------------------------------

## Package Vintage Convention

Each package release captures a **vintage** — the latest annual year
included. The vintage is recorded in the S3 path
(`data_raw/vintage_YYYY/`, `data_processed/vintage_YYYY/`).

| Vintage      | Latest Annual Year | Approx. Capture Date    |
|--------------|--------------------|-------------------------|
| vintage_2024 | 2024 (final)       | September 2025 or later |
| vintage_2025 | 2025 (final)       | September 2026 or later |

When capturing a new vintage, record the capture date and the
`ruraldefinitions` package version used for geographic crosswalks (see
data_infrastructure_review.md).
