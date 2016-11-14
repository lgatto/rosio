## rosio_env <- new.env(parent = emptyenv())

BASEURL2 <- "https://api.opensensors.io/v2"
BASEURL1 <- "https://api.opensensors.io/v1"
BASEURL <- "https://api.opensensors.io"


dataset <- function(id, user) {
    if (missing(user)) { ## assuming public dataset
        URL <- paste0(BASEURL2, "/public/datasets/", id)
        hd <- add_headers()
    } else {
        URL <- paste0(BASEURL2, "/datasets/", id)
        hd <- add_headers(Authorization = paste('api-key', key(user)))
    }
    got <- GET(URL, hd)
    stop_for_status(got)
    suppressMessages(res <- fromJSON(content(got, type = "text")))
    class(res) <- "RosioDataset"
    res
}

print.RosioDataset <- function(x, ...) {
    cat("A", ifelse(x$public, "public", ""),
        "RosioDataSet\n")
    cat(" Id:", x$id, " ")
    cat(" Name:", x$name, "\n")
    cat(" | ")
    cat(strwrap(x$description), sep = "\n | ")
    cat(" Schema:\n")
    sch <- as.character(x$schema)
    nms <- names(x$schema)
    for (i in seq_along(sch))
        cat("  ", nms[i], ": ", sch[i], "\n", sep = "")
}

device <- function(id) {
    res <- list(id = id)
    class(res) <- "RosioDevice"
    res
}

print.RosioDevice <- function(x, ...) {
    cat("A Rosio device with id:", x$id, "\n")
}

messages <- function(x, ...) UseMethod("messages")

messages.RosioDataset <- function(x, duration, ...) {
    stopifnot(inherits(x, "RosioDataset"))
    URL <- paste0(BASEURL2, "/public/messages/dataset/", x$id)
    if (!missing(duration))
        URL <- paste0(URL, "?duration=", duration)
    got <- GET(URL)
    stop_for_status(got)
    suppressMessages(res <- fromJSON(content(got, type = "text"))$messages)
    res$date <- as.POSIXct((res$date + 0.1)/1000,
                           origin = "1970-01-01 UTC")
    res
}

devices <- function(user) {
    stopifnot(inherits(user, "Rosio"))
    if (.empty(username(user)))
        stop("Can't give devices when username is empty")
    URL <- paste0(BASEURL2, "/users/", username(user), "/devices")
    hd <- add_headers(Authorization = paste('api-key', key(user)))
    got <- GET(URL, hd)
    stop_for_status(got)
    suppressMessages(fromJSON(content(got, type = "text")))
}

messages.RosioDevice <- function(dev, user,
                                 start.date,
                                 start.time = "12:00",
                                 end.date = format(Sys.time(), "%Y-%m-%d"),
                                 end.time = format(Sys.time(), "%H:%M")) {
    msg1 <- msg2 <- list()
    if (.empty(username(user)))
        stop("I need a api-key to access a user's device.")
    start <- paste(start.date, start.time, sep = "T")
    end <- paste(end.date, end.time, sep = "T")
    URL <- paste0(BASEURL1, "/messages/device/", dev$id,
                  "?start-date=", url_encode(start), "Z",
                  "&end-date=", url_encode(end), "Z")
    hd <- add_headers(Authorization = paste('api-key', key(user)))
    got <- GET(URL, hd)
    stop_for_status(got)
    suppressMessages(got <- fromJSON(content(got, type = "text"),
                                     flatten = TRUE))
    i <- 1
    .msg <- got[["messages"]]
    msg1[[i]] <- .msg[, 1:6]    
    if (isjson <- .msg$`payload.content-type`[1] == "application/json")
        msg2[[i]] <- stream_in(textConnection(.msg[[7]]),
                               flatten = TRUE, verbose = FALSE)
    else msg2[[i]] <- .msg[[7]]
    while (!is.null(got[["next"]])) {
        i <- i + 1
        URL <- paste0(BASEURL, got[["next"]])
        got <- GET(URL, hd)
        stop_for_status(got)
        suppressMessages(got <- fromJSON(content(got, type = "text"),
                                         flatten = TRUE))
        .msg <- got[["messages"]]
        msg1[[i]] <- .msg[, 1:6]
        if (isjson)
            msg2[[i]] <- stream_in(textConnection(.msg[[7]]),
                                   flatten = TRUE, verbose = FALSE)
        else msg2[[i]] <- .msg[[7]]

    }
    msg1 <- dplyr::bind_rows(msg1)
    if (isjson) msg2 <- dplyr::bind_rows(msg2)
    else msg2 <- unlist(msg2)
    cbind(msg1, msg2)
}
