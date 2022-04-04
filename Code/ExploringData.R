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

florida_hurricane_edit <- florida_hurricane %>%
  mutate(year = year(Date)) %>%
  filter(year >= 1991) %>%
  mutate(Daily_Discharge_clean = zoo::na.approx(Daily_Discharge))

ggplot(florida_hurricane_edit, aes(x = Date, y = Daily_Discharge))+
  geom_point()

f_month <- month(first(florida_hurricane_edit$Date))
f_year <- year(first(florida_hurricane_edit$Date))

#florida_month_ts <- ts(florida_hurricane_edit$Daily_Discharge,
                 #  start=c(f_year,f_month),
                #   frequency= 7) 

florida_month_trend <- trend::smk.test(florida_month_ts)
florida_month_trend
summary(florida_month_trend)


#day??
florida_hurricane_ts <- ts(florida_hurricane_edit$Daily_Discharge_clean, start=c(1991,6), frequency = 153)  
florida_hurricane_ts

florida_hurricane_Decomposed <- stl(florida_hurricane_ts, s.window = "periodic")
plot(florida_hurricane_Decomposed)


florida_hurricane_Decomposed_Components <- as.data.frame(florida_hurricane_Decomposed$time.series[,2:3])
florida_hurricane_Decomposed_Components <- florida_hurricane_Decomposed_Components %>%
  mutate(data = trend + remainder) 


#16
#run time series on new data with seasonal removed

nonseasonal_data_florida_ts <- ts(florida_hurricane_Decomposed_Components$data,
                                start=c(1991,6),
                                frequency=153) 
plot(nonseasonal_data_florida_ts)

florida_trend <- MannKendall(nonseasonal_data_florida_ts)
florida_trend
summary(florida_trend)