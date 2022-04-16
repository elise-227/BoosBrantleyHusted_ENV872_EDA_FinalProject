#load packages
library(tidyverse)
library(lubridate)
library(zoo)
library(trend)
library(dygraphs)
library(xts)
library(ggfortify)
require(dplyr)
library(Kendall)
library(tseries)

florida_hurricane_1990 <- read.csv("./Data/Processed/florida_hurricane_1990_processed.csv", 
                                   stringsAsFactors = T)
#setting date column as date 
florida_hurricane_1990$Date <- as.Date(florida_hurricane_1990$Date, format = '%Y-%m-%d')

#regular time series
florida_hurricane_ts <- ts(florida_hurricane_1990$Daily_Discharge_clean, start=c(1990,6), frequency = 153)  
florida_hurricane_ts

#decomposed time series
florida_hurricane_Decomposed <- stl(florida_hurricane_ts, s.window = "periodic")
plot(florida_hurricane_Decomposed)
#filtering out seasonal data
florida_hurricane_Decomposed_Components <- as.data.frame(florida_hurricane_Decomposed$time.series[,2:3])
florida_hurricane_Decomposed_Components <- florida_hurricane_Decomposed_Components %>%
  mutate(data = trend + remainder) 
#add date column
florida_hurricane_Decomposed_Components <- mutate(florida_hurricane_Decomposed_Components,
                                                  Date = florida_hurricane_1990$Date)

#run time series on new data with seasonal removed
nonseasonal_data_florida_ts <- ts(florida_hurricane_Decomposed_Components$data,
                                  start=c(1990,6),
                                  frequency=153) 
plot(nonseasonal_data_florida_ts)

#look for trend and significance 
florida_trend <- MannKendall(nonseasonal_data_florida_ts)
florida_trend
summary(florida_trend)

#plot of nonseasonal trend
FL_NonSeasonal.Plot <- ggplot(florida_hurricane_Decomposed_Components, aes(x = Date, y = data)) +
  scale_y_log10() +
  geom_point(color = "deeppink1", size = 0.6) +
  labs(x = "Date", y = "Non-Seasonal Daily Discharge (cfs)", 
       title = "Non-Seasonal Mean Daily Discharge During Hurricane Seasons", 
       subtitle = "North Prong St. Sebastian River, Florida") +
  geom_smooth(method = "lm", color = "black") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 year") +
  theme(axis.text.x = element_text(angle = 90)) 
plot(FL_NonSeasonal.Plot)      
