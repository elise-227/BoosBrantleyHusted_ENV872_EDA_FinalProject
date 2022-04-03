#set/check working directory
getwd()

#load in packages
library(tidyverse)
library(lubridate)
library(zoo)
library(trend)
library(dygraphs)
library(xts)

#Load in Data
NY_Discharge <- read.csv("Data/Raw/NY_MeanDailyDischarge.csv")
NY_AnnualPeakDischarge <- read.csv("Data/Raw/NYAnnualPeakFlowDischarge.csv")

#Format Date
NY_Discharge$Date <- as.Date(NY_Discharge$Date, format = "%m/%d/%Y")
NY_AnnualPeakDischarge$Date <- as.Date(NY_AnnualPeakDischarge$Date, format = "%m/%d/%Y")

#Clean Up Data
#rename and remove columns
NY_Discharge.processed <-
  NY_Discharge %>%
  rename(Agency = agency_,
         SiteNumber = cd.......site_no,
         MeanDischarge = X104599_00060_00003) %>%
  select(Agency, SiteNumber, MeanDischarge, Month, Date) %>%
  drop_na() %>%
  filter(Month > 5, Month < 11)
view(NY_Discharge.processed)

#rename and remove columns
NY_AnnualPeakDischarge.processed <-
  NY_AnnualPeakDischarge %>%
  rename(Agency = agenc,
         SiteNumber = y_cd.......site_,
         AnnualPeakDischarge = peak_va) %>%
  select(Agency, SiteNumber, AnnualPeakDischarge, Month, Date) %>%
  drop_na() %>%
  filter(Month > 5, Month < 11)
view(NY_AnnualPeakDischarge.processed)


#Daily Discharge Plot
ggplot(NY_Discharge.processed, aes(x = Date, y = MeanDischarge)) +
  geom_line()

#NY Daily Discharge time-series
NY_DailyDischarge.ts <- ts(NY_Discharge.processed$MeanDischarge, start = c(1950,01), frequency = 365)
head(NY_DailyDischarge.ts, 10)
#Decompose
NY_DailyDischarge.decompose <- stl(NY_DailyDischarge.ts, s.window = "periodic")
plot(NY_DailyDischarge.decompose)


#create time-series object
NY_DischargeTimeSeries <- xts(x = NY_Discharge.processed$MeanDischarge,
                            order.by = NY_Discharge.processed$Date)

#create a basic interactive element
NY_Interact_time <- dygraph(NY_DischargeTimeSeries)
NY_Interact_time

#create a basic interactive element
NY_Interact_time2 <- dygraph(discharge_timeSeries) %>%
  dyRangeSelector()
NY_Interact_time2

