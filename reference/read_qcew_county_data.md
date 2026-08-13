# Read raw BLS QCEW county data for a single year

Downloads (if needed), unzips, and reads the BLS QCEW county high-level
Excel file for the given year. Returns the raw BLS data with cleaned
column names and normalized geoids.

## Usage

``` r
read_qcew_county_data(year, staging_dir = "data/qcew", keep_industries = FALSE)
```

## Arguments

- year:

  Integer. Year to read (1990 or later).

- staging_dir:

  Character. Directory containing zip files. Default: `"data/qcew"`.

- keep_industries:

  Logical. If `FALSE` (default), return only the all-industry total row.
  If `TRUE`, return all industry rows.
