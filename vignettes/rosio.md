---
title: "Opensensors.io using R"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Opensensors.io using R}
---

# `rosio`: opensensors.io in `R`

> The `rosio` package is in very early development. It will be updated
> regularly and current functionality is very likely to evolve. Enjoy
> at your own risks!

## Introduction

We have a set of
[devices](https://opensensorsio.helpscoutdocs.com/article/36-how-do-i-create-a-new-device)
that publish information to a specific
[topic](https://opensensorsio.helpscoutdocs.com/article/38-how-do-i-create-a-new-topic). The
topic essentially contains all the raw data packets that are sent by
the device(s) that publish with it. Not all that data is usable. A
dataset is the cleaned/usable subset of a topic, and multiple datasets
form a project.

Devices, topcis, datasets and projects are set up by
[users](https://publisher.opensensors.io/signup), that can belong to
[organisations](https://opensensorsio.helpscoutdocs.com/article/46-create-and-manage-an-organisation). As
a user, you will have an identifier and a unique API key.

<!-- In the rest of this document, we will be using data from the -->
<!-- [*London air quality network* organisation](https://publisher.opensensors.io/orgs/london-air-quality-network). -->

Let's get started


```r
library("rosio")
```

```
## 
## This is rosio version 0.0.1
```


## Data streams

Data is accessed through datasets, which are instantiated as `dataset`
objects. The data is then retrieved using the `messages`
function. Similarly, devices are created with the `device` function
and data is retrieved with the `messages` function. 

## Authentication

We are going to explore publicly available topics/datasets here. To
access your own private devices, topics, ... you will need a valid
username and
[API key](https://opensensorsio.helpscoutdocs.com/article/42-where-is-my-api-key)
(or, alternatively,
[JWT](https://opensensorsio.helpscoutdocs.com/article/53-using-jwt-for-authentication)).

This is handled by the `Rosio` class, that stores the user's username,
password, API key and JWT token, or any subset thereof. For example,
to create the `Rosio` objet matching user `rosio` with API key
authentication method.


```r
(usr <- Rosio("rosio", key = "e770424c-e62f-49ff-adf1-2f72c49a3c89"))
```

```
## Welcome, rosio user rosio 
## Authentication method(s): API key
```

The `username`, `password`, `key` and `jwt` functions can be used to
access and replace the different fields.

If a password is provided, the `getJWttoken` function can be used to
add a JWT token to the user object. In case of doubt, users can ask
themselves


```r
whoami(usr)
```

```
## [1] "rosio"
```

## A public dataset

Let's have a look at dataset number 77.


```r
(kw <- dataset(77))
```

```
## A public RosioDataSet
##  Id: 77   Name: kirkwall temperature 
##  | Hourly observation reports recorded by the Met Office UK
##  | Monitoring System. Updated every 30 minutes.
##  Schema:
##   type: float
##   unit: celsius
##   category: temperature
```

As it is public, we won't need any authentical method and thus can
ignore pasing any user information when querying for the data
(messages) from that dataset. Below, we ask for the messages published
during the last hour.


```r
messages(kw, duration = 3600)
```

```
##                  date payload
## 1 2016-11-15 18:31:00     9.7
## 2 2016-11-15 19:01:01     9.7
```

## Devices

To get a user's devices


```r
devices(usr)
```

```
##   client-id                                      description       name
## 1      5424 rosio's first test device with password 2tO06pxZ rosiodev01
##           tags location.lat location.lon location.elevation
## 1 test1, test2     52.20121    0.1219482                 25
```


```r
(dev <- device(5424))
```

```
## A Rosio device with id: 5424
```


```r
messages(dev, usr, start.date = "2016-11-14")
```

```
##   device owner                     topic                     date
## 1   5424 rosio         /users/rosio/test 2016-11-14T21:16:32.030Z
## 2   5424 rosio         /users/rosio/test 2016-11-14T21:16:56.257Z
## 3   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:19:51.542Z
## 4   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:19:52.427Z
## 5   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:20:00.671Z
## 6   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:20:18.487Z
## 7   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:21:04.078Z
## 8   5424 rosio /users/rosio/rosiotopic01 2016-11-14T21:22:52.871Z
##   payload.encoding payload.content-type
## 1            utf-8                 NULL
## 2            utf-8                 NULL
## 3            utf-8                 NULL
## 4            utf-8                 NULL
## 5            utf-8                 NULL
## 6            utf-8                 NULL
## 7            utf-8                 NULL
## 8            utf-8                 NULL
##                                                 msg2
## 1                                   My first message
## 2                                  My second message
## 3                                  My second message
## 4                                  My second message
## 5                                   My third message
## 6 And first second message was actally first message
## 7                               Encore un message...
## 8                                 Un altro messaggio
```
