test_that("Assign defensive and field is not NULL", {
    tokt <- as.tokens(split(parsed_ukimmig2010$token, parsed_ukimmig2010$doc_id)) %>% tokens_add_tokenvars()
    expect_error(tokenvars(tokt, "aaa") <- c(1,2,3))
    expect_error(tokenvars(tokt, "aaa") <- list(c(1,2,3)), "Mismatch")
    expect_error(tokenvars(tokt, field = "pos") <- split(parsed_ukimmig2010$upos, parsed_ukimmig2010$doc_id), NA)
})

test_that("Assign field is NULL", {
    tokt <- as.tokens(split(parsed_ukimmig2010$token, parsed_ukimmig2010$doc_id)) %>% tokens_add_tokenvars()
    value <- split(parsed_ukimmig2010[, 5:10], parsed_ukimmig2010$doc_id)
    tokt2 <- tokt
    expect_error(tokenvars(tokt2) <- value, NA)
    value2 <- value
    value2[[2]] <- NA
    expect_error(tokenvars(tokt) <- value2)
    value2 <- value
    value2[[1]] <- head(value2[[1]])
    expect_error(tokenvars(tokt) <- value2)
})
