# Return the current latest QCEW vintage name from S3

Reads the `_LATEST` pointer file written by
[`write_qcew_processed_to_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/write_qcew_processed_to_s3.md)
and returns the vintage string (e.g., `"2024"`).

## Usage

``` r
latest_qcew_vintage(s3_bucket = "cori.data.qcew")
```

## Arguments

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.qcew"`.

## Value

Character. The current vintage label (e.g., `"vintage_2024"`).

## See also

[`read_qcew_from_s3`](https://ruralinnovation.github.io/cori.data.qcew/reference/read_qcew_from_s3.md)
