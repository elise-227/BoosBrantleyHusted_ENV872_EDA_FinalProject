#set/check working directory
getwd()

#load in packages
library(tidyverse)
library(lubridate)
library(zoo)
library(dplyr)
library(trend)
library(dygraphs)
library(xts)
library(ggfortify)

#Load in Data
NY_Discharge <- read.csv("Data/Raw/NY_MeanDailyDischarge.csv", stringsAsFactors = T)

#format date
NY_Discharge$Date <- as.Date(NY_Discharge$Date, format = "%m/%d/%Y")

# filling missing data with linear interpolation
NY_Daily.Discharge.Clean <-
  NY_Discharge %>%
  mutate(MeanDischargeClean = zoo::na.approx(X104599_00060_00003))
view(NY_Daily.Discharge.Clean)

#Wrangle Data
NY_Discharge.processed <-
  NY_Daily.Discharge.Clean %>%
  dplyr::rename(Agency = agency_,
         SiteNumber = cd.......site_no,
         MeanDischarge = MeanDischargeClean) %>%
  select(Agency, SiteNumber, MeanDischarge, Month, Date, Year) %>%
  filter(Month > 5, Month < 11,
         Date >= "1990-06-01")
view(NY_Discharge.processed)



#saving processed file as a csv
write.csv(NY_Discharge.processed, "./Data/Processed/NY_DischargeData_Processed", row.names = FALSE)
