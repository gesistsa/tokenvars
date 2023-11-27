is_system_tokenvars <- function(x) {
    x %in% c("tokennames_", "order_")
}

remove_columns <- function(x, user = TRUE, system = FALSE) {
    x[,user * !is_system_tokenvars(colnames(x)) | system * is_system_tokenvars(colnames(x)), drop = FALSE]
}

select_tokenvars <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE, docnames = NULL, tokennames = NULL) {
    ## x is attr(x, "tokenvars"), list of data.frames
    if (!is.null(docnames)) {
        x <- x[docnames]
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
tokenvars <- function(x, field = NULL, docnames = NULL, tokennames = NULL) {
    ## place holder; TODO field and tokennames
    select_tokenvars(attr(x, "docvars")$tokenvars_, field = field, docnames = docnames, tokennames = tokennames, drop = TRUE)
}

#' @export
"tokenvars<-" <- function(x, field = NULL, value) {
    x_tokenvars <- attr(x, "docvars")$tokenvars_
    for (i in seq_along(value)) {
        if (length(value[[i]]) != 1 && length(value[[i]]) != nrow(x_tokenvars[[i]])) {
            stop("Mismatch.", call. = TRUE)
        }
        attr(x, "docvars")$tokenvars_[[i]][[field]] <- value[[i]]
    }
    return(x)
}

#' @export
tokens_add_tokenvars <- function(x, tokennames = NULL) {
    unclassed_x <- unclass(x)
    unclassed_x <- add_tokennames(unclassed_x, tokennames)
    attr(unclassed_x, "docvars")$tokenvars_ <- I(make_tokenvars(unclassed_x))
    class(unclassed_x) <- c("tokens_with_tokenvars")
    return(unclassed_x)
}

#' @importFrom quanteda as.tokens
#' @method as.tokens tokens_with_tokenvars
#' @export
as.tokens.tokens_with_tokenvars <- function(x, remove_tokenvars = TRUE, ...) {
    if (remove_tokenvars) {
        attr(x, "docvars")$tokenvars_ <- NULL
    }
    class(x) <- "tokens"
    return(x)
}

#' @export
#' @method docvars tokens_with_tokenvars
#' @importFrom quanteda docvars
docvars.tokens_with_tokenvars <- function(x, field = NULL) {
    ## TODO remove tokenvars_
    return(docvars(as.tokens(x, remove_tokenvars = TRUE), field = field))
}

print_item <- function(x, flatten, tokennames) {
    for (i in seq_along(x)) {
        cat(tokennames[i], ">\"", x[i], "\"", sep = "")
        if (flatten[i] != "") {
            cat("(", flatten[i], ")", sep = "")
        }
        cat(" ")
    }
}

flat_tokenvars <- function(df) {
    vapply(seq_len(nrow(df)), function(y) paste(as.character(df[y,]), collapse = "|"), "")
}

#' @export
print.tokens_with_tokenvars <- function(x, max_ndoc = quanteda::quanteda_options("print_tokens_max_ndoc"),
               max_ntoken = quanteda::quanteda_options("print_tokens_max_ntoken"),
               show_summary = quanteda::quanteda_options("print_tokens_summary"), ...) {
    ## modified from quanteda::print.tokens
    ##print(as.tokens(x, remove_tokenvars = FALSE), max_ndoc = max_ndoc, max_ntoken = max_ntoken, show_summary = show_summary)
    ndoc <- length(x)
    docvars <- docvars(x)
    xtokenvars <- tokenvars(x)
    if (max_ndoc < 0) {
        max_ndoc <- ndoc
    }
    if (show_summary) {
        cat("Tokens consisting of ", format(ndoc, big.mark = ","), " document",
            if (ndoc != 1L) "s" else "", sep = "")
        if (ncol(docvars)) {
            cat(" and ", format(ncol(docvars), big.mark = ","), " docvar",
                if (ncol(docvars) != 1L) "s" else "", sep = "")
        }
        cat(".\n")
        if (ncol(xtokenvars[[1]])) {
            cat("Token variables: (", paste(names(xtokenvars[[1]]), collapse = "|"), ").\n", sep = "")
        }
    }
    if (max_ndoc > 0 && ndoc > 0) {
        subsetted_x <- head(x, max_ndoc)
        xtokenvars <- head(xtokenvars, max_ndoc)
        docnamess <- paste0(names(subsetted_x), " :")
        types <- c("", attr(x, "types"))
        len <- lengths(subsetted_x)
        if (max_ntoken < 0) {
            max_ntoken <- max(len)
        }
        tokens_to_display <- lapply(unclass(subsetted_x), function(y) types[head(y, max_ntoken) + 1])
        flatten_tokenvars <- lapply(xtokenvars, flat_tokenvars)
        tokennames <- lapply(subsetted_x, names)
        for (i in seq_along(docnamess)) {
            cat(docnamess[i], "\n", sep = "")
            print_item(tokens_to_display[[i]], flatten_tokenvars[[i]], tokennames[[i]])
            if (len[i] > max_ntoken) {
                cat("{ ... and ",  format(len[i] - max_ntoken, big.mark = ","), " more }\n", sep = "")
            }
            cat("\n", sep = "")
        }
        ndoc_rem <- ndoc - max_ndoc
        if (ndoc_rem > 0) {
            cat("{ reached max_ndoc ... ", format(ndoc_rem, big.mark = ","), " more document",
                if (ndoc_rem > 1) "s", " }\n", sep = "")
        }
    }
}

make_tokenvars <- function(unclassed_x) {
    output <- list()
    for (i in seq_along(unclassed_x)) {
        output[[i]] <- data.frame(tokennames_ = names(unclassed_x[i][[1]]),
                                order_ = seq_along(names(unclassed_x[i][[1]])))
    }
    names(output) <- attr(unclassed_x, "docvars")$docname_
    return(output)
}

add_tokennames <- function(unclassed_x, tokennames = NULL) {
    ## using attr(vec, "names") as tokennames; apparently, the original implmentation of quanteda::tokens()
    ## doesn't care about those names
    if (is.null(tokennames)) {
        for (i in seq_along(unclassed_x)) {
            attr(unclassed_x[[i]], "names") <- paste0("t", seq_along(unclassed_x[[i]]))
        }
        return(unclassed_x)
    }
    for (i in seq_along(unclassed_x)) {
        attr(unclassed_x[[i]], "names") <- tokennames[[i]]
    }
    return(unclassed_x)
}
