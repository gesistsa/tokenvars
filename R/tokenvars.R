tokenvars <- function(x, field) {
    ## place holder
}

add_token_id <- function(x) {
    ## using attr(vec, "names") as token_id
    unclassed_x <- unclass(x)
    for (i in seq_along(unclassed_x)) {
        attr(unclassed_x[[i]], "names") <- paste0("t", seq_along(unclassed_x[[i]]))
    }
    class(unclassed_x) <- c("tokens")
    return(unclassed_x)
}
