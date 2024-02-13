test_that("defensive", {
    expect_error(tokens_proximity("a", "a"), "x is not a")
})

## test_that("edge cases", {
##     expect_error("" %>% tokens() %>% tokens_proximity("") %>% convert(), NA)
## })

test_that("count_from", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my life" %>% tokens() %>% tokens_proximity("my") %>% tokenvars("proximity") -> res
    expect_equal(res$text1, c(3, 2, 1, 2))
    "this is my life" %>% tokens() %>% tokens_proximity("my", count_from = 0) %>% tokenvars("proximity") -> res
    expect_equal(res$text1, c(2, 1, 0, 1))
    ## crazy sh*t
    "this is my life" %>% tokens() %>% tokens_proximity("my", count_from = -1) %>% tokenvars("proximity") -> res
    expect_equal(res$text1, c(1, 0, -1, 0))
})

test_that("convert", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my life" %>% tokens() %>% tokens_proximity("my") %>% convert() -> res
    expect_true(is.data.frame(res))
})

test_that("convert no strange rownames, #39", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my life" %>% tokens() %>% tokens_proximity("my") %>% convert() -> res
    expect_true(is.data.frame(res))
    expect_equal(rownames(res), c("t1", "t2", "t3", "t4")) ## default rownames
})

test_that("Changing pattern", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my life" %>% tokens() %>% tokens_proximity("my") -> res
    expect_error(res2 <- tokens_proximity(res, "life"), NA)
    expect_equal(meta(res2, "pattern"), "life")
})

test_that("token_proximity() only emit token_proximity #35", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my life" %>% tokens() %>% tokens_proximity("my") -> res
    expect_false("tokens" %in% class(res)) # no tokens
    expect_error(tokens_select(res, "life"))
    expect_error(tokens_select(as.tokens(res), "life"), NA)
})

test_that("tolower", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my MIT life" %>% tokens() %>% tokens_proximity("my") -> res
    expect_false("MIT" %in% attr(res, "types"))
    "this is my MIT life" %>% tokens() %>% tokens_proximity("my", tolower = FALSE) -> res
    expect_true("MIT" %in% attr(res, "types"))
    "this is my MIT life" %>% tokens() %>% tokens_proximity("my", tolower = TRUE, keep_acronyms = TRUE) -> res
    expect_true("MIT" %in% attr(res, "types"))
    expect_true("tolower" %in% names(meta(res)))
    expect_true("keep_acronyms" %in% names(meta(res)))    
})

test_that("case_insensitive", {
    suppressPackageStartupMessages(library(quanteda))
    "this is my MIT life" %>% tokens() %>% tokens_proximity("MIT") -> res
    expect_false("MIT" %in% attr(res, "types"))
    expect_equal(tokenvars(res, "proximity")$text1, c(4, 3, 2, 1, 2))
    "this is my MIT life" %>% tokens() %>% tokens_proximity("MIT", case_insensitive = FALSE) -> res
    expect_false("MIT" %in% attr(res, "types"))
    expect_equal(tokenvars(res, "proximity")$text1, c(6, 6, 6, 6, 6))    
})

test_that("phrase", {
    suppressPackageStartupMessages(library(quanteda))
    expect_error("Seid ihr das Essen? Nein, wir sind die Jäger." %>% tokens() %>% tokens_proximity(phrase("das Essen")) -> res, NA)
    expect_equal(tokenvars(res, "proximity")$text1, c(3,2,1,1,2,3,4,5,6,7,8,9))
})

## dfm

test_that("normal", {
    suppressPackageStartupMessages(library(quanteda))
    testdata <-
        c("Turkish President Tayyip Erdogan, in his strongest comments yet on the Gaza conflict, said on Wednesday the Palestinian militant group Hamas was not a terrorist organisation but a liberation group fighting to protect Palestinian lands.")
    res <- testdata %>% tokens() %>% tokens_proximity(pattern = "turkish")
    res %>% dfm() -> output
    expect_equal(as.numeric(output[1,"in"]), 0.166666, tolerance = 0.0001)
})

test_that("weight function", {
    suppressPackageStartupMessages(library(quanteda))
    testdata <-
        c("Turkish President Tayyip Erdogan, in his strongest comments yet on the Gaza conflict, said on Wednesday the Palestinian militant group Hamas was not a terrorist organisation but a liberation group fighting to protect Palestinian lands.")
    res <- testdata %>% tokens() %>% tokens_proximity(pattern = "turkish")
    res %>% dfm(weight_function = identity) -> output2
    expect_equal(as.numeric(output2[1,","]), 20, tolerance = 0.0001)
})

test_that("tolower", {
    suppressPackageStartupMessages(library(quanteda))
    testdata <-
        c("Turkish President Tayyip Erdogan, in his strongest comments yet on the Gaza conflict, said on Wednesday the Palestinian militant group Hamas was not a terrorist organisation but a liberation group fighting to protect Palestinian lands.")
    res <- testdata %>% tokens() %>% tokens_proximity(pattern = "turkish", tolower = FALSE)
    res %>% dfm(tolower = TRUE) -> output
    expect_true("turkish" %in% colnames(output))
    res %>% dfm(tolower = FALSE) -> output
    expect_false("turkish" %in% colnames(output))
    res <- testdata %>% tokens() %>% tokens_proximity(pattern = phrase("Tayyip Erdogan"), tolower = FALSE)
    res %>% dfm(tolower = TRUE) -> output
    expect_true("turkish" %in% colnames(output))
})

test_that("Padding #46", {
    suppressPackageStartupMessages(library(quanteda))
    toks <- tokens(c("a b c", "A B C D")) %>% tokens_remove("b", padding = TRUE)
    expect_error(toks %>% tokens_proximity("a") %>% dfm(), NA)
})

test_that("remove_padding", {
    suppressPackageStartupMessages(library(quanteda))
    toks <- tokens(c("a b c", "A B C D")) %>% tokens_remove("b", padding = TRUE)
    output <- toks %>% tokens_proximity("a") %>% dfm()
    expect_true("" %in% colnames(output))
    output <- toks %>% tokens_proximity("a") %>% dfm(remove_padding = TRUE)
    expect_false("" %in% colnames(output))
})

## infra

test_that("docvars retention", {
    suppressPackageStartupMessages(library(quanteda))
    test <- c("hello world!")
    corpus(test, docvars = data.frame(dummy = TRUE)) -> test_corpus
    meta(test_corpus, "what") <- "test"
    expect_equal(test_corpus %>% tokens() %>% dfm() %>% docvars("dummy"), TRUE)
    expect_equal(test_corpus %>% tokens() %>% tokens_proximity(pattern = "world") %>% dfm() %>% docvars("dummy"), TRUE)
    ## remove_docvars_dist
    docvars_cols <- test_corpus %>% tokens() %>% tokens_proximity(pattern = "world") %>% dfm(remove_tokenvars = FALSE) %>% docvars() %>% colnames()
    expect_true("tokenvars_" %in% docvars_cols)
    docvars_cols <- test_corpus %>% tokens() %>% tokens_proximity(pattern = "world") %>% dfm(remove_tokenvars = TRUE) %>% docvars() %>% colnames()
    expect_false("tokenvars" %in% docvars_cols)
})

test_that("meta retention", {
    suppressPackageStartupMessages(library(quanteda))
    test <- c("hello world!")
    corpus(test, docvars = data.frame(dummy = TRUE)) -> test_corpus
    meta(test_corpus, "what") <- "test"
    expect_equal(test_corpus %>% tokens() %>% dfm() %>% meta("what"), "test")
    expect_equal(test_corpus %>% tokens() %>% tokens_proximity(pattern = "world") %>% dfm() %>% meta("what"), "test")
})

test_that("docvars and meta methods", {
    suppressPackageStartupMessages(library(quanteda))
    test <- c("hello world!")
    expect_equal(tokens(test) %>% tokens_proximity("world") %>% docvars() %>% colnames(), "tokenvars_")
    expect_error(tokens(test) %>% tokens_proximity("world") %>% meta(), NA)
})
