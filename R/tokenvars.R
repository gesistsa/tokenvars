is_system_tokenvars <- function(x) {
    x %in% c("tokenid_", "order_")
}

remove_columns <- function(x, user = TRUE, system = FALSE) {
    x[,user * !is_system_tokenvars(colnames(x)) | system * is_system_tokenvars(colnames(x)), drop = FALSE]
}

select_tokenvars <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE, docid = NULL, tokenid = NULL) {
    ## x is attr(x, "tokenvars"), list of data.frames
    if (!is.null(docid)) {
        x <- x[docid]
    }
    x <- lapply(x, remove_columns, user = user, system = system)
    if (is.null(field)) {
        return(x)
    }
    if (length(field) == 1 && drop) {
        return(lapply(x, `[[`, field))
    }
    return(lapply(x, `[`, field))
}

#' @export
tokenvars <- function(x, field = NULL, docid = NULL, tokenid = NULL) {
    ## place holder; TODO field and tokenid
    select_tokenvars(attr(x, "tokenvars"), field = field, docid = docid, tokenid = tokenid, drop = TRUE)
}

#' @export
"tokenvars<-" <- function(x, field = NULL, value) {
    x_tokenvars <- attr(x, "tokenvars")
    for (i in seq_along(value)) {
        if (length(value[[i]]) != 1 && length(value[[i]]) != nrow(x_tokenvars[[i]])) {
            stop("Mismatch.", call. = TRUE)
        }
        attr(x, "tokenvars")[[i]][[field]] <- value[[i]]
    }
    return(x)
}

#' @export
tokens_add_tokenvars <- function(x) {
    unclassed_x <- unclass(x)
    unclassed_x <- add_tokenid(unclassed_x)
    attr(unclassed_x, "tokenvars") <- make_tokenvars(unclassed_x)
    class(unclassed_x) <- c("tokens")
    return(unclassed_x)
}

make_tokenvars <- function(unclassed_x) {
    output <- list()
    for (i in seq_along(unclassed_x)) {
        output[[i]] <- data.frame(tokenid_ = names(unclassed_x[i][[1]]),
                                order_ = seq_along(names(unclassed_x[i][[1]])))
    }
    names(output) <- attr(unclassed_x, "docvars")$docname_
    return(output)
}

add_tokenid <- function(unclassed_x) {
    ## using attr(vec, "names") as token_id; apparently, the original implmentation of quanteda::tokens()
    ## doesn't care about those names
    for (i in seq_along(unclassed_x)) {
        attr(unclassed_x[[i]], "names") <- paste0("t", seq_along(unclassed_x[[i]]))
    }
    return(unclassed_x)
}

pp <- function(x, max_ndoc = quanteda::quanteda_options("print_tokens_max_ndoc"),
               max_ntoken = quanteda::quanteda_options("print_tokens_max_ntoken"),
               show_summary = quanteda::quanteda_options("print_tokens_summary"), ...) {
    ## Pretty print; probably I can't hijack quanteda::print.tokens
    if (is.null(attr(x, "tokenvars"))) {
        print(x, max_ndoc = max_ndoc, max_ntoken = max_ntoken, show_summary = show_summary, ...)
        return(invisible(NULL))
    }
    
}
