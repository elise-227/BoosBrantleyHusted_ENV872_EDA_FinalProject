require(lubridate)
require(tidyverse)
#load data
florida_1990 <- read.csv("./Data/Processed/florida_hurricane_1990_processed.csv", stringsAsFactors = T)
#Date column
florida_1990 <- florida_1990 %>%
  mutate(Date = ymd(Date))

class(florida_1990$Date)

#plot discharge before running time series on the log scale
ggplot(florida_1990, aes(x = Date, y = log(Daily_Discharge_clean)))+
  geom_point(color = "deeppink1")+
  geom_smooth(method = lm, color = "black")+
  labs(x = "Date", y = "Mean Daily Discharge (cfs)",
       title = "Mean Daily Discharge During Hurrcane Seasons (1990-2021)", 
       subtitle = ", Florida") 
