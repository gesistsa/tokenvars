## usethis namespace: start
#' @useDynLib tokenvars, .registration = TRUE
## usethis namespace: end
NULL

#' @useDynLib tokenvars row_mins_
row_mins_c <- function(mat) {
    .Call("row_mins_", mat, as.integer(nrow(mat)), as.integer(ncol(mat)))
}

cal_dist <- function(from, to, poss) {
    return(pmin(abs(to - poss), abs(from - poss)))
}

cal_dist_singular <- function(from, to, poss) {
    return(abs(from - poss))
}

get_proximity <- function(x, pattern, get_min = TRUE, count_from = 1, valuetype, case_insensitive) {
    output <- list()
    idx <- quanteda::index(x, pattern = pattern, valuetype = valuetype, case_insensitive = case_insensitive)
    singular_pattern_only <- all(idx$to == idx$from)
    if (singular_pattern_only) {
        cal_func <- cal_dist_singular
    } else {
        cal_func <- cal_dist
    }
    nt <- as.numeric(quanteda::ntoken(x))
    dn <- quanteda::docnames(x)
    for (i in seq_along(x)) {
        if (dn[i] %in% idx$docname) {
            poss <- seq_len(nt[i])
            matched_rows <- idx$docname == dn[i]
            res <- mapply(cal_func, from = idx$from[matched_rows], to = idx$to[matched_rows], MoreArgs = list("poss" = poss))
            if (get_min) {
                output[[i]] <- row_mins_c(res) + count_from
            } else {
                output[[i]] <- res
            }
        } else {
            output[[i]] <- rep(nt[i] + count_from, nt[i])
        }
    }
    names(output) <- quanteda::docnames(x)
    return(output)
}

pp <- function(pattern) {
    ## pretty print the pattern if it contains phrases
    if (!is.list(pattern)) {
        return(pattern)
    }
    return(vapply(pattern, paste, collapse = " ", character(1)))
}

#' Extract Proximity Information
#'
#' This function extracts distance information from a [quanteda::tokens()] object.
#' @param x a `tokens` or `tokens_with_proximity` object.
#' @param pattern pattern for selecting keywords, see [quanteda::pattern] for details.
#' @param get_min logical, whether to return only the minimum distance or raw distance information; it is more relevant when `keywords` have more than one word. See details.
#' @param valuetype See [quanteda::valuetype].
#' @param case_insensitive logical, see [quanteda::valuetype].
#' @param count_from numeric, how proximity is counted from when `get_min` is `TRUE`. The keyword is assigned with this proximity. Default to 1 (not zero) to prevent division by 0 with the default behaviour of [dfm.tokens_with_proximity()].
#' @param tolower logical, convert all features to lowercase.
#' @param keep_acronyms logical, if `TRUE`, do not lowercase any all-uppercase words. See [quanteda::tokens_tolower()].
#' @details Proximity is measured by the number of tokens away from the keyword. Given a tokenized sentence: \["I", "eat", "this", "apple"\] and suppose "eat" is the keyword. The vector of minimum proximity for each word from "eat" is \[2, 1, 2, 3\], if `count_from` is 1. In another case: \["I", "wash", "and", "eat", "this", "apple"\] and \["wash", "eat"\] are the keywords. The minimal distance vector is \[2, 1, 2, 1, 2, 3\]. If `get_min` is `FALSE`, the output is a list of two vectors. For "wash", the distance vector is \[1, 0, 1, 2, 3\]. For "eat", \[3, 2, 1, 0, 1, 2\].
#' Please conduct all text manipulation tasks with `tokens_*()` functions before calling this function. To convert the output back to a `tokens` object, use [quanteda::as.tokens()].
#' @return a `tokens_with_proximity` object. It is similar to [quanteda::tokens()], but only [dfm.tokens_with_proximity()], [quanteda::convert()], [quanteda::docvars()], and [quanteda::meta()] methods are available. A `tokens_with_proximity` has a modified [print()] method. Also, additional data slots are included
#' * a document variable `proximity`
#' * metadata slots for all arguments used
#' @examples
#' library(quanteda)
#' tok1 <- data_char_ukimmig2010 %>%
#'     tokens(remove_punct = TRUE) %>%
#'     tokens_tolower() %>%
#'     tokens_proximity(c("eu", "euro*"))
#' tok1 %>%
#'     dfm() %>%
#'     dfm_select(c("immig*", "migr*")) %>%
#'     rowSums() %>%
#'     sort()
#' ## compare with
#' data_char_ukimmig2010 %>%
#'     tokens(remove_punct = TRUE) %>%
#'     tokens_tolower() %>%
#'     dfm() %>%
#'     dfm_select(c("immig*", "migr*")) %>%
#'     rowSums() %>%
#'     sort()
#' ## rerun to select other keywords
#' tok1 %>% tokens_proximity("britain")
#' @seealso [dfm.tokens_with_proximity()] [quanteda::tokens()]
#' @export
tokens_proximity <- function(x, pattern, get_min = TRUE, valuetype = c("glob", "regex", "fixed"), case_insensitive = TRUE, count_from = 1,
                             tolower = TRUE, keep_acronyms = FALSE) {
    if (!inherits(x, "tokens") && !inherits(x, "tokens_with_proximity")) {
        stop("x is not a `tokens` or `tokens_with_proximity` object.", call. = FALSE)
    }
    if (inherits(x, "tokens_with_proximity")) {
        x <- as.tokens(x, remove_docvars_proximity = TRUE)
    }
    if (tolower) {
        x <- quanteda::tokens_tolower(x, keep_acronyms = keep_acronyms)
    }
    valuetype <- match.arg(valuetype)
    proximity <- get_proximity(x = x, pattern = pattern, get_min = get_min, count_from = count_from,
                               valuetype = valuetype, case_insensitive = case_insensitive)
    toks <- x
    ## ## only for printing
    quanteda::meta(toks, field = "pattern") <- pp(pattern)
    attr(toks, "pattern") <- pattern ## custom field
    quanteda::meta(toks, field = "get_min") <- get_min
    quanteda::meta(toks, field = "valuetype") <- valuetype
    quanteda::meta(toks, field = "case_insensitive") <- case_insensitive
    quanteda::meta(toks, field = "count_from") <- count_from
    quanteda::meta(toks, field = "tolower") <- tolower
    quanteda::meta(toks, field = "keep_acronyms") <- keep_acronyms
    toks <- tokens_add_tokenvars(toks)
    tokenvars(toks, "proximity") <- proximity
    class(toks) <- append(class(toks), c("tokens_with_proximity"))
    return(toks)
}

convert_df <- function(tokens_obj, proximity_obj, doc_id) {
    return(data.frame(
        "doc_id" = rep(doc_id, length(tokens_obj)),
        "token" = tokens_obj,
        "proximity" = proximity_obj
    ))
}

#' @method print tokens_with_proximity
#' @export
print.tokens_with_proximity <- function(x, ...) {
    print(as.tokens(x), ...)
    cat("With proximity vector(s).\n")
    cat("Pattern: ", quanteda::meta(x, field = "pattern"), "\n")
}

#' @importFrom quanteda as.tokens
#' @method as.tokens tokens_with_proximity
#' @export
as.tokens.tokens_with_proximity <- function(x, concatenator = "/", remove_docvars_proximity = TRUE, ...) {
    if (remove_docvars_proximity) {
        attr(x, which = "docvars")$proximity <- NULL
        attr(x, which = "pattern") <- NULL
    }
    class(x) <- "tokens"
    return(x)
}

#' @importFrom quanteda docvars
#' @method docvars tokens_with_proximity
#' @export
docvars.tokens_with_proximity <- function(x, field = NULL) {
    return(quanteda::docvars(as.tokens(x, remove_docvars_proximity = FALSE), field = field))
}

#' @importFrom quanteda meta
#' @method meta tokens_with_proximity
#' @export
meta.tokens_with_proximity <- function(x, field = NULL, type = c("user", "object", "system", "all")) {
    return(quanteda::meta(as.tokens(x, remove_docvars_proximity = FALSE), field = field, type = type))
}

#' @method convert tokens_with_proximity
#' @export
#' @importFrom quanteda convert
convert.tokens_with_proximity <- function(x, to = c("data.frame"), ...) {
    to <- match.arg(to)
    x_docnames <- attr(x, "docvars")$docname_
    result_list <- mapply(
        FUN = convert_df,
        tokens_obj = as.list(x),
        proximity_obj = tokenvars(x, "proximity"),
        doc_id = x_docnames,
        SIMPLIFY = FALSE, USE.NAMES = FALSE
    )
    return(do.call(rbind, result_list))
}

tokens_proximity_tolower <- function(x) {
    ## update from inside, docvars(x, "proximity") is updated too.
    return(tokens_proximity(x, pattern = attr(x, "pattern"),
                     get_min = quanteda::meta(x, "get_min"),
                     valuetype = quanteda::meta(x, "valuetype"),
                     case_insensitive = quanteda::meta(x, "case_insensitive"),
                     count_from = quanteda::meta(x, "count_from"),
                     tolower = TRUE, keep_acronyms = quanteda::meta(x, "count_from"))
           )
}

## port from quanteda
catm <- function(..., sep = " ", appendLF = FALSE) {
    message(paste(..., sep = sep), appendLF = appendLF)
}

#' Create a document-feature matrix
#'
#' Construct a sparse document-feature matrix from the output of [tokens_proximity()].
#' @param x output of [tokens_proximity()].
#' @param tolower convert all features to lowercase.
#' @param remove_padding logical; if `TRUE`, remove the "pads" left as empty tokens after calling [quanteda::tokens()] or [quanteda::tokens_remove()] with `padding = TRUE`.
#' @param remove_tokenvars logical, remove tokenvars in the returned dfm.
#' @param verbose  display messages if `TRUE`.
#' @param weight_function a weight function, default to invert distance,
#' @param ... not used.
#' @importFrom quanteda dfm
#' @return a [quanteda::dfm-class] object
#' @details By default, words closer to keywords are weighted higher. You might change that with another `weight_function`.
#' @examples
#' library(quanteda)
#' tok1 <- data_char_ukimmig2010 %>%
#'     tokens(remove_punct = TRUE) %>%
#'     tokens_tolower() %>%
#'     tokens_proximity(c("eu", "europe", "european"))
#' tok1 %>%
#'     dfm() %>%
#'     dfm_select(c("immig*", "migr*")) %>%
#'     rowSums() %>%
#'     sort()
#' ## Words further away from keywords are weighted higher
#' tok1 %>%
#'     dfm(weight_function = identity) %>%
#'     dfm_select(c("immig*", "migr*")) %>%
#'     rowSums() %>%
#'     sort()
#' tok1 %>%
#'     dfm(weight_function = function(x) {
#'         1 / x^2
#'     }) %>%
#'     dfm_select(c("immig*", "migr*")) %>%
#'     rowSums() %>%
#'     sort()
#' @method dfm tokens_with_proximity
#' @export
dfm.tokens_with_proximity <- function(x, tolower = TRUE, remove_padding = FALSE,
                                      verbose = quanteda::quanteda_options("verbose"), remove_tokenvars = TRUE,
                                      weight_function = function(x) {
                                          1 / x
                                      }, ...) {
    if (!quanteda::meta(x, "tolower") && tolower) {
        x <- tokens_proximity_tolower(x)
    }
    x_attrs <- attributes(x)
    x_docvars <- quanteda::docvars(x)
    x_docnames <- attr(x, "docvars")$docname_
    temp <- unclass(x)
    index <- unlist(temp, use.names = FALSE)
    type <- attr(x, "types")
    if (0 %in% index) {
        index <- index + 1
        type <- c("", type)
    }
    if (!quanteda::meta(x, "get_min")) {
        if (verbose) {
            catm("Only the minimum proximity is used.\n")
        }
        count_from <- meta(x, "count_from")
        tokenvars(x, "proximity") <- lapply(tokenvars(x, "proximity"), function(y) row_mins_c(y) + count_from)
    }
    val <- weight_function(unlist(tokenvars(x, "proximity"), use.names = FALSE))
    temp <- Matrix::sparseMatrix(
        j = index,
        p = cumsum(c(1L, lengths(x))) - 1L,
        x = val,
        dims = c(
            length(x),
            length(type)
        ),
        dimnames = list(x_docnames, type)
    )
    output <- quanteda::as.dfm(temp)
    attributes(output)[["meta"]] <- x_attrs[["meta"]]
    if (remove_tokenvars) {
        x_docvars$tokenvars_ <- NULL
    }
    quanteda::docvars(output) <- x_docvars
    if (remove_padding) {
        output <- quanteda::dfm_select(output, pattern = "", select = "remove", valuetype = "fixed", padding = FALSE,
                                       verbose = verbose)
    }
    return(output)
}
