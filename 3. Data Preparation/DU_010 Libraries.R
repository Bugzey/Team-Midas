rm(list = ls())

#######################
# load some libraries #
#######################
pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}
pkgTest("geohash")
pkgTest("tidyverse")
pkgTest("readr")
pkgTest("data.table")

