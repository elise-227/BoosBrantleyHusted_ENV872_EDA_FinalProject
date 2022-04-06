#load packages
require(tidyverse)
require(dplyr)
require(lubridate)
library(trend)
library(zoo)
library(Kendall)
library(tseries)
require(sf)
require(leaflet)
require(mapview)
mapviewOptions(fgb = FALSE)

#read in both sheets of the data since data was too big to fit on one
florida_part2 <- read.csv("./Data/Raw/florida_round2.csv", stringsAsFactors = T)
florida_part2_join <- read.csv("./Data/Raw/florida_round2_1.csv", stringsAsFactors = T)
#join the two datasets
join <- rbind(florida_part2, florida_part2_join)
#clean the original florida dataset
florida_clean <- join %>%
  mutate(Date = ymd(Date)) %>%
  mutate(State = "Florida") %>%
  select(State, Date, Discharge)
#days with multiple observations summarise to get mean and filter out only hurricane months
florida_hurricane <- florida_clean %>%
  group_by(Date) %>%
  summarise(Daily_Discharge = mean(Discharge)) %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) 
#create a date dataframe of timespan
Date  <- seq(as.Date("1987-01-01"),as.Date("2021-10-31"), by = "days")
Dates <- as.data.frame(Date)
#filter out hurricane months
date_join <- Dates %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) %>%
  select(1)
#join the data sets to allow us to know which days don't have observations
#interpolate the days with NAs
fh_clean <-left_join(date_join, florida_hurricane, by = "Date")
fh_clean <- fh_clean %>%
  select(1,2) %>%
  mutate(Daily_Discharge_clean = zoo::na.approx(Daily_Discharge))
#trimming data set for comparison, starting at 1990
florida_1990_edit <- fh_clean %>%
  mutate(year = year(Date)) %>%
  filter(year >= 1990) 

#regular time series
florida_hurricane_ts <- ts(florida_1990_edit$Daily_Discharge_clean, start=c(1990,6), frequency = 153)  
florida_hurricane_ts

#decomposed time series
florida_hurricane_Decomposed <- stl(florida_hurricane_ts, s.window = "periodic")
plot(florida_hurricane_Decomposed)
#filtering out seasonal data
florida_hurricane_Decomposed_Components <- as.data.frame(florida_hurricane_Decomposed$time.series[,2:3])
florida_hurricane_Decomposed_Components <- florida_hurricane_Decomposed_Components %>%
  mutate(data = trend + remainder) 

#run time series on new data with seasonal removed
nonseasonal_data_florida_ts <- ts(florida_hurricane_Decomposed_Components$data,
                                start=c(1990,6),
                                frequency=153) 
plot(nonseasonal_data_florida_ts)

#look for trend and significance 
florida_trend <- MannKendall(nonseasonal_data_florida_ts)
florida_trend
summary(florida_trend)

#plot discharge on the log scale
ggplot(florida_1990_edit, aes(x = Date, y = log(Daily_Discharge_clean)))+
  geom_point(color = "hot pink")+
  geom_smooth(method = lm, color = "black")+
  labs(title = "Discharge in Florida during Hurricane Months over Time")+
  xlab("Date") +
  ylab("Mean Daily Discharge (ft^3/s)")

#map of gage sites 
site_locations <- read.csv("./Data/Raw/Site_locations.csv", stringsAsFactors = T)
site_locations.sf <- site_locations %>%
st_as_sf(coords = c('Long','Lat'),
         crs=4269)
mapview(site_locations.sf, zcol = "Site.Name")
