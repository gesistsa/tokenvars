
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tokenvars

<!-- badges: start -->

<!-- badges: end -->

The goal of tokenvars is to …

## Installation

You can install the development version of tokenvars like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Proof of concept

This is a basic example which shows you how to solve a common problem:

``` r
library(quanteda)
#> Package version: 3.3.1
#> Unicode version: 14.0
#> ICU version: 70.1
#> Parallel computing: 8 of 8 threads used.
#> See https://quanteda.io for tutorials and examples.
library(tokenvars)

x <- tokens(c("this is great", "not so great man")) %>% tokens_add_tokenvars()
x
#> Tokens consisting of 2 documents.
#> text1 :
#> [1] "this"  "is"    "great"
#> 
#> text2 :
#> [1] "not"   "so"    "great" "man"
```

``` r
tokenvars(x)
#> $text1
#>   token_id_ order_
#> 1        t1      1
#> 2        t2      2
#> 3        t3      3
#> 
#> $text2
#>   token_id_ order_
#> 1        t1      1
#> 2        t2      2
#> 3        t3      3
#> 4        t4      4
```
