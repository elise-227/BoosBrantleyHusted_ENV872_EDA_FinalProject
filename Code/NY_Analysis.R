#set/check working directory
getwd()

#load in packages
library(tidyverse)
library(lubridate)
library(zoo)
library(trend)
library(dygraphs)
library(xts)
library(ggfortify)

#Load in Data
NY_Discharge <- read.csv("Data/Raw/NY_MeanDailyDischarge.csv", stringsAsFactors = T)

#Format Date
NY_Discharge$Date <- as.Date(NY_Discharge$Date, format = "%m/%d/%Y")

# filling missing data with linear interpolation
NY_Daily.Discharge.Clean <-
  NY_Discharge %>%
  mutate(MeanDischargeClean = zoo::na.approx(X104599_00060_00003))
view(NY_Daily.Discharge.Clean)

#Wrangle Data
NY_Discharge.processed <-
  NY_Daily.Discharge.Clean %>%
  rename(Agency = agency_,
         SiteNumber = cd.......site_no,
         MeanDischarge = MeanDischargeClean) %>%
  select(Agency, SiteNumber, MeanDischarge, Month, Date, Year) %>%
  filter(Month > 5, Month < 11,
         Date >= "1990-06-01")
view(NY_Discharge.processed)


#NY Daily Discharge time-series
NY_DailyDischarge.ts <- ts(NY_Discharge.processed$MeanDischarge, start = c(1990,01), frequency = 153)
head(NY_DailyDischarge.ts, 10)

#Decompose
NY_DailyDischarge.decompose <- stl(NY_DailyDischarge.ts, s.window = "periodic")
plot(NY_DailyDischarge.decompose)

#Nonseasonal MannKendall
NY_Components <- as.data.frame(NY_DailyDischarge.decompose$time.series[,2:3])
view(NY_Components)

#Add in a date column
NY_Components <- mutate(NY_Components,
                        Date = NY_Discharge.processed$Date)

#Adding non-seasonal component to dataframe
NY_Combine_Nonseasonal <- mutate(NY_Components, Nonseasonal = NY_Components$trend + NY_Components$remainder)
view(NY_Combine_Nonseasonal)

#Nonseasonal time series
NY_Nonseasonal.ts <- ts(NY_Combine_Nonseasonal$Nonseasonal, start= c(1990, 1), frequency = 153)

#MannKendall Nonseasonal Analysis
NY_Trend.Nonseasonal <- Kendall::MannKendall(NY_Nonseasonal.ts)
NY_Trend.Nonseasonal

#tau = 0.13; p-value = less than 0.05
#the null hypothesis of the test (i.e., Seasonal Mann Kendall) states that the data is stationary
#reject null hypothesis and we state that there is a trend





