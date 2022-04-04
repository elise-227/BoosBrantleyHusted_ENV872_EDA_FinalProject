require(tidyverse)
require(dplyr)
require(lubridate)
library(trend)
library(zoo)
library(Kendall)
library(tseries)

florida <- read.csv("./Data/Raw/Discharge_NorthCanal_FL_Raw3.csv", stringsAsFactors = T)

florida_clean <- florida %>%
  mutate(Date = mdy(datetime)) %>%
  mutate(Discharge = X30943_00060) %>%
  mutate(State = "Florida") %>%
  select(State, site_no, Date, Discharge)

florida_hurricane <- florida_clean %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) %>%
  group_by(Date) %>%
  summarise(Daily_Discharge = mean(Discharge)) %>%
  mutate(State = "Florida")



ggplot(florida_hurricane, aes(x = Date, y = Daily_Discharge))+
  geom_point()

f_month <- month(first(florida_hurricane$Date))
f_year <- year(first(florida_hurricane$Date))
florida_month_ts <- ts(florida_hurricane$Daily_Discharge,
                   start=c(f_year,f_month),
                   frequency= 7) 

florida_month_trend <- trend::smk.test(florida_month_ts)
florida_month_trend
summary(florida_month_trend)


#day??
florida_hurricane_ts <- ts(florida_hurricane$Daily_Discharge, start=c(f_year,f_month), frequency = 153)  
florida_hurricane_ts

florida_hurricane_Decomposed <- stl(florida_hurricane_ts, s.window = "periodic")
plot(florida_hurricane_Decomposed)
