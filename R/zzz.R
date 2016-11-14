.onAttach <- function(lib, pkg) {
    packageStartupMessage(paste("\nThis is rosio version",
                                packageVersion("rosio"), "\n"))
}
