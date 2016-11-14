.Rosio <- setClass("Rosio",
                   representation =
                       list(username = "character",
                            password = "character",
                            jwt = "character",
                            key = "character"))

.empty <- function(x) x == ""

.emptyRosio <- function(user)
    any(c(.empty(username(user)),
          .empty(password(user)),
          .empty(key(user))))


Rosio <- function(username = "",
                  key = "",
                  jwt = "",
                  password = "") {
    .Rosio(username = username,
           password = password,
           jwt = jwt,
           key = key)
}

setMethod("show", "Rosio",
          function(object) {
              if (.empty(object@username)) {
                  cat("Unknown rosio user.\n")
              } else {
                  cat("Welcome, rosio user",
                      object@username, "\n")
                  auths <- c()
                  if (object@key != "") auths <- c(auths, "API key")
                  if (object@jwt != "") auths <- c(auths, "JWT")
                  cat("Authentication method(s): ")
                  if (length(auths))
                      cat(paste(auths, collapse = ", "), "\n")
                  else cat("none\n")
              }
          })

username <- function(x) x@username
password <- function(x) x@password
jwt <- function(x) x@jwt
key <- function(x) x@key


"username<-" <- function(x, value) {
    stopifnot(inherits(x, "Rosio"))
    x@username <- as.character(value)
    x
}

"key<-" <- function(x, value) {
    stopifnot(inherits(x, "Rosio"))
    x@key <- as.character(value)
    x
}

"password<-" <- function(x, value) {
    stopifnot(inherits(x, "Rosio"))
    x@password <- as.character(value)
    x
}

"jwt<-" <- function(x, value) {
    stopifnot(inherits(x, "Rosio"))
    x@jwt <- as.character(value)
    x
}

whoami <- function(user) {
    stopifnot(inherits(user, "Rosio"))
    if (.empty(user@key))
        stop("I need an api-key to tell you who you are.")
    URL <- "https://api.opensensors.io/v2/whoami"
    hd <- add_headers(Authorization = paste('api-key', user@key))
    got <- GET(URL, hd)
    suppressMessages(fromJSON(content(got, type = "text"))[[1]])
}

getJWTtoken <- function(user) {
    stopifnot(inherits(user, "Rosio"))
    if (.emptyRosio(user))
        stop("I need username, password and api-key to retrieve a JWT token.")
    URL <- "https://api.opensensors.io/v2/login"
    hd <- add_headers(Authorization = paste('api-key', user@key))
    body <- paste0('{"username": "', username(user), '",',
                   '"password": "', password(user), '"}')    
    got <- POST(URL, hd, body = body)
    jwt(user) <- content(got)[[1]]
    user
}
