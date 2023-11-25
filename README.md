
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

corp <- corpus(c(d1 = "spaCy is great at fast natural language processing.",
                 d2 = "Mr. Smith spent two years in North Carolina."))

tok <- tokens(corp) %>% tokens_add_tokenvars()
tok
#> Tokens consisting of 2 documents.
#> d1 :
#> [1] "spaCy"      "is"         "great"      "at"         "fast"      
#> [6] "natural"    "language"   "processing" "."         
#> 
#> d2 :
#>  [1] "Mr"       "."        "Smith"    "spent"    "two"      "years"   
#>  [7] "in"       "North"    "Carolina" "."
```

``` r
tokenvars(tok) ## nothing to see here
#> $d1
#> data frame with 0 columns and 9 rows
#> 
#> $d2
#> data frame with 0 columns and 10 rows
```

``` r
tokenvars(tok, "tag") <- list(c("NNP", "VBZ", "JJ", "IN", "JJ", "JJ", "NN", "NN", "."),
                              c("NNP", ".", "NNP", "VBD", "CD", "NNS", "IN", "NNP", "NNP", "."))
```

``` r
tokenvars(tok)
#> $d1
#>   tag
#> 1 NNP
#> 2 VBZ
#> 3  JJ
#> 4  IN
#> 5  JJ
#> 6  JJ
#> 7  NN
#> 8  NN
#> 9   .
#> 
#> $d2
#>    tag
#> 1  NNP
#> 2    .
#> 3  NNP
#> 4  VBD
#> 5   CD
#> 6  NNS
#> 7   IN
#> 8  NNP
#> 9  NNP
#> 10   .
```

``` r
tokenvars(tok, field = "tag")
#> $d1
#> [1] "NNP" "VBZ" "JJ"  "IN"  "JJ"  "JJ"  "NN"  "NN"  "."  
#> 
#> $d2
#>  [1] "NNP" "."   "NNP" "VBD" "CD"  "NNS" "IN"  "NNP" "NNP" "."
```

``` r
tokenvars(tok, field = "tag", docid = "d1")
#> $d1
#> [1] "NNP" "VBZ" "JJ"  "IN"  "JJ"  "JJ"  "NN"  "NN"  "."
```
