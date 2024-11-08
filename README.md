# cashflows.R

Simple functions for visualizing and discounting cash flows (DCF) in R

## What is cashflows.R?

cashflows.R is a small R file with cashflow-related functions. Currently supported operations are:

- [creating new cashflow objects based on vectors of transaction values and periods](#cashflowpayments-periods),
- creating cashflows for [bonds](#bondprincipal-maturity-couponrate-boughtfor) and [annuities](#annuityperiod-amount-due),
- [merging two or more cashflow objects into one](#cfmerge),
- [calculating the value of a cashflow in time with compound interest](#timevaluecf-v-i-t-ascashflow),
- [calculating the value of a cashflow in time with simple interest](#simpletimevaluecf-i-method-t-ascashflow), using one of two methods:
    - equivalent cash flows,
    - retrospective-prospective.

## Usage

You can add cashflows.R functions to your script or working environment directly from Github by using

``` r
source("https://github.com/pawelmajcher/cashflows.R/blob/main/cashflows.R?raw=true")
```

> [!CAUTION]
> This code is not actively maintained as of now, but is subject to change. If you rely on the current behavior of the code, consider downloading the code or using the raw link to a specific version.

## Functions

### cashflow(payments, periods)

The `cashflow` function takes a vector with the value of each transaction and a vector with its (unit-agnostic, numeric) execution time, and orders them and returns a list with two vector elements (payments and periods).

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:-----|:-------------------------|:-----------------------|:---------------|
| `payments` | vector with transaction values            | numeric vector of any length                  | Yes                               |
| `periods`  | vector with transaction time | numeric vector equal in length to `payments` | No, `1:length(payments)` by default |

#### Examples

``` r
cashflow_example_1 = cashflow(payments = c(10,30,40,10))
cashflow_example_1
```

    ## $payments
    ## [1] 10 30 40 10
    ## 
    ## $periods
    ## [1] 1 2 3 4

``` r
cashflow_example_2 = cashflow(payments = c(10,20,30), periods = c(0,2,5))
cashflow_example_2
```

    ## $payments
    ## [1] 10 20 30
    ## 
    ## $periods
    ## [1] 0 2 5

### cfmerge(…)

The `cfmerge` function merges any number of cashflows as defined above into one. Multiple transactions made in the same period are joined into one (a sum).

#### Examples

``` r
cashflow_example_3 = cfmerge(cashflow_example_1, cashflow_example_2, cashflow(-100, periods=5))
cashflow_example_3
```

    ## $payments
    ## [1]  10  10  50  40  10 -70
    ## 
    ## $periods
    ## [1] 0 1 2 3 4 5

### cfmatrix(cf, vertical)

The `cfmatrix` function returns the cashflow as a matrix.

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:----|:--------------------------------|:----------------|:-----------------|
| `cf`       | the cashflow to represent as a matrix                                                            | output of another function | Yes                                                 |
| `vertical` | TRUE if transactions are to be assigned per row | boolean                                   | No, `FALSE` by default (transactions assigned per column) |

#### Examples

``` r
cfmatrix(cashflow_example_2)
```

    ##        Payment 1 Payment 2 Payment 3
    ## Period         0         2         5
    ## Amount        10        20        30

``` r
cfmatrix(cashflow_example_3, vertical=TRUE)
```

    ##           Period Amount
    ## Payment 1      0     10
    ## Payment 2      1     10
    ## Payment 3      2     50
    ## Payment 4      3     40
    ## Payment 5      4     10
    ## Payment 6      5    -70

### annuity(period, amount, due)

The `annuity` function returns a cashflow based on parameters of an annuity.

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:----|:----------------|:--------------------------------|:-----------------|
| `period` | number of periods (length) of annuity | positive integer or `Inf` (perpetuity approximated by 10,000) | Yes                                      |
| `amount` | payment amount                         | numeric                                                                        | No, `1` by default                       |
| `due`    | annuity paid upfront                  | boolean                                                              | No, `FALSE` by default (annuity paid in arrear) |

#### Examples

``` r
cashflow_example_4 = annuity(period = 6, amount = 150, due = TRUE)
cfmatrix(cashflow_example_4)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6
    ## Period         0         1         2         3         4         5
    ## Amount       150       150       150       150       150       150

### bond(principal, maturity, couponRate, boughtFor)

The `bond` function returns a cashflow based on parameters of a bond.

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:------|:-------------------|:-----------------|:----------------------------|
| `principal`  | the principal value of a bond                | numeric                                | Tak                                                              |
| `maturity`   | termin zapadalności obligacji              | positive integer                      | Tak                                                              |
| `couponRate` | constant or variable coupon rate | numeric or numeric vector of the length equal to value of `maturity` | No, 0 by default (zero-coupon bond)                        |
| `boughtFor`  | the price paid for the bond at point zero  | numeric                                | No, 0 by default (bond purchase not included in the cashflow) |

#### Examples

``` r
cashflow_example_5 = bond(principal = 5000, maturity = 5, couponRate = 0.03)
cfmatrix(cashflow_example_5)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5
    ## Period         1         2         3         4         5
    ## Amount       150       150       150       150      5150

``` r
cashflow_example_6 = bond(principal = 20, maturity = 10, boughtFor = 10)
cfmatrix(cashflow_example_6)
```

    ##        Payment 1 Payment 2
    ## Period         0        10
    ## Amount       -10        20

### timevalue(cf, v, i, t, as.cashflow)

The `timevalue` function calculates the value of a cashflow at a given time for given interest rates, using compound interest.

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:------|:-------------------------|:--------------------|:------------------|
| `cf`          | the cashflow to discount                          | output of another function   | Yes                                            |
| `v`           | discount factor(s)                           | numeric or numeric vector of the same length as `cf$payments` vector | Yes, unless `i` defined                |
| `i`           | interest rate(s)                                 | numeric or numeric vector of the same length as `cf$payments` vector | Yes, unless `v` defined                |
| `t`           | time we calculate the value of cashflow for                                  | numeric                                               | No, 0 by default (present value)              |
| `as.cashflow` | return a cashflow with values discounted separately for each period | boolean                                     | No, `FALSE` by default (total numeric value returned) |

> [!WARNING]
> You can use either `v` or `i`, but using both in one function execution will return an error.

> [!TIP]
> You can use `presentvalue` as a shortcut for `timevalue` if `t` is equal to zero.

#### Examples

``` r
# How much is each annuity payment worth in Example 4? Let's assume interest rates are decreasing each period starting with 5 p. p.

cashflow_example_4_rates = seq(0.06, 0.01, by=-0.01)
cashflow_example_4_present_values = timevalue(cashflow_example_4, i = cashflow_example_4_rates, as.cashflow = TRUE)
cfmatrix(cashflow_example_4_present_values)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6
    ## Period         0    1.0000    2.0000    3.0000    4.0000    5.0000
    ## Amount       150  142.8571  138.6834  137.2712  138.5768  142.7199

``` r
# What will be the value of the bond from Example 5 at its maturity date, assuming a constant discount factor of 0.98?

cashflow_example_5_maturity_value = timevalue(cashflow_example_5, v = 0.98, t = 5)
cashflow_example_5_maturity_value
```

    ## [1] 5781.243

``` r
# How much money do we make by buying a bond from Example 6, assuming a 5% constant interest rate?

cashflow_example_6_present_value = timevalue(cashflow_example_6, i = 0.05)
cashflow_example_6_present_value
```

    ## [1] 2.278265

### simpletimevalue(cf, i, method, t, as.cashflow)

The `timevalue` function calculates the value of a cashflow at a given time for given interest rates, using simple interest.

#### Arguments

| Name      | Description                                                      | Possible values                                   | Required                          |
|:----|:------------------------------------|:---------------|:--------------|
| `cf`          | the cashflow to discount                                                                                    | output of another function   | Yes                                            |
| `i`           | interest rate(s)                                                                                           | numeric or numeric vector of the same length as `cf$payments` vector | Yes                                            |
| `t`           | time we calculate the value of cashflow for                                                                                            | numeric                                               | No, 0 by default (present value)              |
| `method`      | method of calculating cash flow value (equivalent flows or retrospective/prospective method) | `e` or `rp`                                         | Yes, unless `t == 0` (with identical results regardless of method)                         |
| `as.cashflow` | return a cashflow with values discounted separately for each period                                                           | boolean                                     | No, `FALSE` by default (total numeric value returned) |

#### Examples

``` r
# What will be the value of the bond from Example 5 at its maturity date, assuming a constant simple interest rate of 7 p.p.?

cashflow_example_5_maturity_value_si_rp = simpletimevalue(cashflow_example_5, i = 0.07, t = 5, method = "rp")
cashflow_example_5_maturity_value_si_e = simpletimevalue(cashflow_example_5, i = 0.07, t = 5, method = "e")

# results for retrospective/prospective and equivalent flows method:
c(cashflow_example_5_maturity_value_si_rp, cashflow_example_5_maturity_value_si_e)
```

    ## [1] 5855.000 5842.442

``` r
# How much money do we make by buying a bond from Example 6, assuming a 5% constant simple interest rate?
cashflow_example_6_present_value_si = simpletimevalue(cashflow_example_6, i = 0.05)
cashflow_example_6_present_value_si
```

    ## [1] 3.333333

## Example exercises

### Exercise 1

Determine the present value of an infinite cash flow that returns $\frac{1}{n}$ for even periods and $\frac{1}{n^2}$ for odd periods, given $i = 2\%$.

<details>

<summary>🔎 Solution code</summary>

``` r
cashflow_task_1_1 = cashflow(periods = 2*(1:10000), payments = 1/(2*(1:10000)))

cashflow_task_1_2 = cashflow(periods = 2*(1:10000) - 1, payments = (1/(2*(1:10000)) - 1)^2)

cashflow_task_1 = cfmerge(cashflow_task_1_1, cashflow_task_1_2)

timevalue(cashflow_task_1, i=0.02)
```

    ## [1] 23.93494

</details>

### Exercise 2

Find the difference between the current value of a 10-year 400 PLN annuity paid upfront and the value of the annuity at the moment of the last payment, assuming constant $i = 10\%$ simple interest.

<details>

<summary>🔎 Solution code</summary>

``` r
cashflow_task_2 = annuity(period = 10, amount = 400, due = TRUE)
cfmatrix(cashflow_task_2)
```

    ##        Payment 1 Payment 2 Payment 3 Payment 4 Payment 5 Payment 6 Payment 7
    ## Period         0         1         2         3         4         5         6
    ## Amount       400       400       400       400       400       400       400
    ##        Payment 8 Payment 9 Payment 10
    ## Period         7         8          9
    ## Amount       400       400        400

``` r
simpletimevalue(cashflow_task_2, i = 0.1, t = 9, method="e") - simpletimevalue(cashflow_task_2, i = 0.1, method="e") 
```

    ## [1] 2587.577

</details>

### Exercise 3

What simple interest rate does a 10-year zero-coupon bond need to have for it to have the same value as the same bond under $i = 5\%$ compound interest rate?

<details>

<summary>🔎 Solution code</summary>

``` r
# bonds with the same principal are equivalent for comparison, assuming 1
cashflow_task_3 = bond(principal = 1, maturity = 10)
for (i in (1:1000)/1000) {
  if (simpletimevalue(cashflow_task_3, i=i) < timevalue(cashflow_task_3, i=0.05)) {
    print(i)
    break()
  }
}
```

    ## [1] 0.063

</details>
