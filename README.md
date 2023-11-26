
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
#> t1>"spaCy" t2>"is" t3>"great" t4>"at" t5>"fast" t6>"natural" t7>"language" t8>"processing" t9>"." 
#> d2 :
#> t1>"Mr" t2>"." t3>"Smith" t4>"spent" t5>"two" t6>"years" t7>"in" t8>"North" t9>"Carolina" t10>"."
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
tok
#> Tokens consisting of 2 documents.
#> Token variables: (tag|lemma).
#> d1 :
#> t1>"spaCy"(NNP|spaCy) t2>"is"(VBZ|be) t3>"great"(JJ|great) t4>"at"(IN|at) t5>"fast"(JJ|fast) t6>"natural"(JJ|natural) t7>"language"(NN|language) t8>"processing"(NN|processing) t9>"."(.|.) 
#> d2 :
#> t1>"Mr"(NNP|Mr) t2>"."(.|.) t3>"Smith"(NNP|Smith) t4>"spent"(VBD|spend) t5>"two"(CD|two) t6>"years"(NNS|year) t7>"in"(IN|in) t8>"North"(NNP|North) t9>"Carolina"(NNP|Carolina) t10>"."(.|.)
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
