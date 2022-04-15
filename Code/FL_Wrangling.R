#load packages
require(tidyverse)
require(dplyr)
require(lubridate)
library(trend)
library(zoo)
library(Kendall)
library(tseries)

#load data
florida_part2 <- read.csv("./Data/Raw/florida_round2.csv", stringsAsFactors = T)
florida_part2_join <- read.csv("./Data/Raw/florida_round2_1.csv", stringsAsFactors = T)
#join the two datasets
join <- rbind(florida_part2, florida_part2_join)

#clean the original florida dataset
florida_clean <- join %>%
  mutate(Date = ymd(Date)) %>%
  select(Date, Discharge)

#days with multiple observations summarise to get mean and make month column
florida_hurricane <- florida_clean %>%
  group_by(Date) %>%
  summarise(Daily_Discharge = mean(Discharge)) %>%
  mutate(month = month(Date))

#create a date dataframe of timespan
Date  <- seq(as.Date("1987-01-23"),as.Date("2021-10-31"), by = "days")
Dates <- as.data.frame(Date)

#join the data sets to allow us to know which days don't have observations
#interpolate the days with NAs
#filter out non-hurricane months and data before 1990
fh_clean <-left_join(Dates, florida_hurricane, by = "Date")
florida_hurricane_1990 <- fh_clean %>%
  mutate(Daily_Discharge_clean = zoo::na.approx(Daily_Discharge)) %>%
  filter(month >= 6 & month <= 10) %>%
  mutate(year = year(Date)) %>%
  filter(year >= 1990) %>%
  select(Date, Daily_Discharge_clean)
  
#save to processed folder 
write.csv(florida_hurricane_1990, "./Data/Processed/flordia_hurricane_1990_processed.csv")

