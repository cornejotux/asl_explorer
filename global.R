## Author: Jorge F. Cornejo
## Date: Jan 24, 2018
## Goal: Create an intereactive presentation to show how
##       escapment have changed over time at the SASAP.Region level

##### This section download the data from KNB and prepare it for Shiny app
rm(list=ls())

library(data.table)
library(dplyr)
require(lubridate)
require(ggplot2)
require(ggjoy)
require(scales)
library(ggthemes)
library(shinythemes)
library(Hmisc)
library(mgcv)

#### WARNING: this dataset is known to have problem!! 
#### This is been used only to develop the shiny app.
asl <- readRDS(file="meanASL.RDS")

#asl$SASAP.Region <- ifelse(asl$SASAP.Region == "Alaska Peninsula and Aleutian Islands", "Ak. Peninsula and Aleutian Is.", asl$SASAP.Region)
#saveRDS(asl, file="meanASL.RDS")
#asl$yday <- yday(asl$sampleDate)
#asl$md <- as.Date(asl$yday, format = "%j", origin = "1.1.2018")

selectYears <- function(data=asl)
{
    minY <- min(data$sampleYear, na.rm = T)
    maxY <- max(data$sampleYear, na.rm = T)
    output <- c(minY, maxY)
    return(output)
}

sp <- c("chinook", "coho", "chum", "pink", "sockeye")
tab <<- 0
S <<- 'sockeye'
R <<- "Ak. Peninsula and Aleutian Is."
