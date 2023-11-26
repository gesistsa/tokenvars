
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
#> 
#> With Token Variables.
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
tokenvars(tok, "lemma") <- list(c("spaCy", "be", "great", "at", "fast", "natural", "language", "processing", "."),
                                c("Mr", ".", "Smith", "spend", "two", "year", "in", "North", "Carolina", "."))
```

``` r
tokenvars(tok)
#> $d1
#>   tag      lemma
#> 1 NNP      spaCy
#> 2 VBZ         be
#> 3  JJ      great
#> 4  IN         at
#> 5  JJ       fast
#> 6  JJ    natural
#> 7  NN   language
#> 8  NN processing
#> 9   .          .
#> 
#> $d2
#>    tag    lemma
#> 1  NNP       Mr
#> 2    .        .
#> 3  NNP    Smith
#> 4  VBD    spend
#> 5   CD      two
#> 6  NNS     year
#> 7   IN       in
#> 8  NNP    North
#> 9  NNP Carolina
#> 10   .        .
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
tokenvars(tok, field = "lemma", docid = "d2")
#> $d2
#>  [1] "Mr"       "."        "Smith"    "spend"    "two"      "year"    
#>  [7] "in"       "North"    "Carolina" "."
```
