<!-- README.md is generated from README.Rmd. Please edit that file -->

# `rosio`: An R interface to OpenSensors.io

[![Linux Build Status](https://travis-ci.org/lgatto/rosio.svg?branch=master)](https://travis-ci.org/rosio)
[![](http://www.r-pkg.org/badges/version/rosio)](http://www.r-pkg.org/pkg/rosio)
<!-- [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/rosio)](http://www.r-pkg.org/pkg/rosio) -->

> The `rosio` package is in very early development. It will be updated
> regularly and current functionality is very likely to evolve. Enjoy
> at your own risks! 

## Installation

```r
devtools::install_github("lgatto/rosio")
```

## Usage


```r
library("rosio")
```

```
## 
## This is rosio version 0.0.1
```

Currently, there is 


```r
ls("package:rosio")
```

```
##  [1] "dataset"     "device"      "devices"     "getJWTtoken" "jwt"        
##  [6] "jwt<-"       "key"         "key<-"       "messages"    "password"   
## [11] "password<-"  "Rosio"       "username"    "username<-"  "whoami"
```

The progress of the package is documented in the
[vignette](https://github.com/lgatto/rosio/blob/master/vignettes/rosio.md). More
documentation will follow soon.

## Questions, bugs, requests

Please use the GitHub
[issues](https://github.com/OpenSensorsIO/rosio/issues).


## License

GPL-2 © [Laurent Gatto](https://github.com/lgatto).
