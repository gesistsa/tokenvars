#' @export
tokenvars <- function(x, field = NULL, docid = NULL, token_id = NULL) {
    ## place holder
    if (is.null(field)) {
        return(attr(x, "tokenvars"))
    }
}

#' @export
tokens_add_tokenvars <- function(x) {
    unclassed_x <- unclass(x)
    unclassed_x <- add_token_id(unclassed_x)
    attr(unclassed_x, "tokenvars") <- generate_tokenvars(unclassed_x)
    class(unclassed_x) <- c("tokens")
    return(unclassed_x)
}

generate_tokenvars <- function(unclassed_x) {
    output <- list()
    for (i in seq_along(unclassed_x)) {
        output[[i]] <- data.frame(token_id_ = names(unclassed_x[i][[1]]),
                                order_ = seq_along(names(unclassed_x[i][[1]])))
    }
    names(output) <- attr(unclassed_x, "docvars")$docname_
    return(output)
}

add_token_id <- function(unclassed_x) {
    ## using attr(vec, "names") as token_id; apparently, the original implmentation of quanteda::tokens()
    ## doesn't care about those names
    for (i in seq_along(unclassed_x)) {
        attr(unclassed_x[[i]], "names") <- paste0("t", seq_along(unclassed_x[[i]]))
    }
    return(unclassed_x)
}
