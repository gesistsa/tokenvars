
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tokenvars

<!-- badges: start -->

<!-- badges: end -->

At the moment, this package is super experimental and cannot be
considered easy to use. Even when it is the case, this is mostly an
infrastructural R package for a very niche category of developers
wanting to develop R packages for
[quanteda](https://github.com/quanteda/quanteda).

`quanteda` has good support for metadata. However, one can only put
corpus- and document-level metadata (`meta()`, `docvars()`,
respectively). This package aims at going down one level and provides
support for token-level metadata. Token-level metadata is useful for
tagging individual token (e.g. Parts of Speech, relationships among
tokens); it is also useful to store upper-level information of tokens
(e.g. the subword tokenized sequence of tokens “\_L”, “’”, “app”, “ar”,
“tement”; you might want to know “\_L” is from the French word
“*L’appartement*”).

## Installation

You can install the development version of tokenvars like so:

``` r
# Well, if you don't know how to do this, you probably shouldn't try this.
```

## A demo of using token-level metadata

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
#> Tokens consisting of 2 documents and 1 docvar.
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
#> Tokens consisting of 2 documents and 1 docvar.
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
tokenvars(tok, field = "lemma", docnames = "d2")
#> $d2
#>  [1] "Mr"       "."        "Smith"    "spend"    "two"      "year"    
#>  [7] "in"       "North"    "Carolina" "."
```

## tokens\_proximity

`tokens_proxmity` is a showcase of `tokenvars` for calculating and
manipulating a token-level metadata. “proximity” is a token-level
metadata of the distance between a target pattern and all other tokens.

``` r
txt1 <-
c("Turkish President Tayyip Erdogan, in his strongest comments yet on the Gaza conflict, said on Wednesday the Palestinian militant group Hamas was not a terrorist organisation but a liberation group fighting to protect Palestinian lands.",
"EU policymakers proposed the new agency in 2021 to stop financial firms from aiding criminals and terrorists. Brussels has so far relied on national regulators with no EU authority to stop money laundering and terrorist financing running into billions of euros.")
tok1 <- txt1 %>% tokens() %>%
    tokens_proximity(pattern = "turkish")
tok1
#> Tokens consisting of 2 documents and 1 docvar.
#> Token variables: (proximity).
#> text1 :
#> t1>"turkish"(1) t2>"president"(2) t3>"tayyip"(3) t4>"erdogan"(4) t5>","(5) t6>"in"(6) t7>"his"(7) t8>"strongest"(8) t9>"comments"(9) t10>"yet"(10) t11>"on"(11) t12>"the"(12) { ... and 26 more }
#> 
#> text2 :
#> t1>"eu"(44) t2>"policymakers"(44) t3>"proposed"(44) t4>"the"(44) t5>"new"(44) t6>"agency"(44) t7>"in"(44) t8>"2021"(44) t9>"to"(44) t10>"stop"(44) t11>"financial"(44) t12>"firms"(44) { ... and 31 more }
```

``` r
tokenvars(tok1, "proximity")
#> $text1
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34 35 36 37 38
#> 
#> $text2
#>  [1] 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44
#> [26] 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44 44
```

The `tokens` object with proximity vectors can be converted to a
(weighted) `dfm` (Document-Feature Matrix). The default weight is
assigned by inverting the proximity.

``` r
dfm(tok1)
#> Document-feature matrix of: 2 documents, 64 features (45.31% sparse) and 0 docvars.
#>        features
#> docs    turkish president    tayyip erdogan         ,         in       his
#>   text1       1       0.5 0.3333333    0.25 0.2666667 0.16666667 0.1428571
#>   text2       0       0   0            0    0         0.02272727 0        
#>        features
#> docs    strongest  comments yet
#>   text1     0.125 0.1111111 0.1
#>   text2     0     0         0  
#> [ reached max_nfeat ... 54 more features ]
```

You have the freedom to change to another weight function. For example,
not inverting.

``` r
dfm(tok1, weight_function = identity)
#> Document-feature matrix of: 2 documents, 64 features (45.31% sparse) and 0 docvars.
#>        features
#> docs    turkish president tayyip erdogan  , in his strongest comments yet
#>   text1       1         2      3       4 20  6   7         8        9  10
#>   text2       0         0      0       0  0 44   0         0        0   0
#> [ reached max_nfeat ... 54 more features ]
```

Or any custom function

``` r
dfm(tok1, weight_function = function(x) { 1 / x^2 })
#> Document-feature matrix of: 2 documents, 64 features (45.31% sparse) and 0 docvars.
#>        features
#> docs    turkish president    tayyip erdogan          ,           in        his
#>   text1       1      0.25 0.1111111  0.0625 0.04444444 0.0277777778 0.02040816
#>   text2       0      0    0          0      0          0.0005165289 0         
#>        features
#> docs    strongest   comments  yet
#>   text1  0.015625 0.01234568 0.01
#>   text2  0        0          0   
#> [ reached max_nfeat ... 54 more features ]
```
