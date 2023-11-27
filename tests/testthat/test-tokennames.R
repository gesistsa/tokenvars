test_that("tokennames", {
    tok <- as.tokens(split(parsed_ukimmig2010$token, parsed_ukimmig2010$doc_id))
    ## default tokennames
    expect_equal(names(tokens_add_tokenvars(tok)[[1]])[1], "t1")
    customized_ids <- paste0(parsed_ukimmig2010$sentence_id, "_", parsed_ukimmig2010$token_id)
    expect_equal(names(tokens_add_tokenvars(tok, tokennames = split(customized_ids, parsed_ukimmig2010$doc_id))[[1]])[1], "1_1")
})
