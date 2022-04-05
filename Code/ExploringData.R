require(tidyverse)
require(dplyr)
require(lubridate)
library(trend)
library(zoo)
library(Kendall)
library(tseries)

florida <- read.csv("./Data/Raw/Discharge_NorthCanal_FL_Raw3.csv", stringsAsFactors = T)

florida_part2 <- read.csv("./Data/Raw/florida_round2.csv", stringsAsFactors = T)
florida_part2_join <- read.csv("./Data/Raw/florida_round2_1.csv", stringsAsFactors = T)


Date  <- seq(as.Date("1987-01-01"),as.Date("2021-10-31"), by = "days")
Dates <- as.data.frame(Date)

date_join <- Dates %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) %>%
  select(1)

fh_clean <-left_join(date_join, florida_hurricane, by = "Date")
summary(fh_clean$Daily_Discharge)

fh_clean <- fh_clean %>%
  select(1,2) %>%
  mutate(Daily_Discharge_clean = zoo::na.approx(Daily_Discharge))

join <- rbind(florida_part2, florida_part2_join)

florida_clean <- join %>%
  mutate(Date = ymd(Date)) %>%
  mutate(State = "Florida") %>%
  select(State, Date, Discharge)

florida_hurricane <- florida_clean %>%
  group_by(Date) %>%
  summarise(Daily_Discharge = mean(Discharge)) %>%
  mutate(Daily_Discharge_clean = zoo::na.approx(Daily_Discharge)) %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) %>%
  mutate(State = "Florida")

florida_1990_edit <- fh_clean %>%
  mutate(year = year(Date)) %>%
  filter(year >= 1990) 

ggplot(florida_hurricane_edit, aes(x = Date, y = Daily_Discharge))+
  geom_point()

f_month <- month(first(florida_hurricane$Date))
f_year <- year(first(florida_hurricane$Date))

#florida_month_ts <- ts(florida_hurricane_edit$Daily_Discharge,
                 #  start=c(f_year,f_month),
                #   frequency= 7) 

#florida_month_trend <- trend::smk.test(florida_month_ts)
#florida_month_trend
#summary(florida_month_trend)



#day??
florida_hurricane_ts <- ts(florida_1990_edit$Daily_Discharge_clean, start=c(1990,6), frequency = 153)  
florida_hurricane_ts

florida_hurricane_Decomposed <- stl(florida_hurricane_ts, s.window = "periodic")
plot(florida_hurricane_Decomposed)


florida_hurricane_Decomposed_Components <- as.data.frame(florida_hurricane_Decomposed$time.series[,2:3])
florida_hurricane_Decomposed_Components <- florida_hurricane_Decomposed_Components %>%
  mutate(data = trend + remainder) 


#16
#run time series on new data with seasonal removed

nonseasonal_data_florida_ts <- ts(florida_hurricane_Decomposed_Components$data,
                                start=c(1990,6),
                                frequency=153) 
plot(nonseasonal_data_florida_ts)

florida_trend <- MannKendall(nonseasonal_data_florida_ts)
florida_trend
summary(florida_trend)
