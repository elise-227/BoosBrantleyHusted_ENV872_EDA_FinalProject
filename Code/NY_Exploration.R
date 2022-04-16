#Load packages
library(tidyverse)
library(lubridate)

NY_Discharge <- read.csv("Data/Processed/NY_DischargeData_Processed", stringsAsFactors = T)
view(NY_Discharge)

#Format Date
NY_Discharge$Date <- as.Date(NY_Discharge$Date, format = "%Y-%m-%d")


#Plot daily discharge prior to running a time-series logged
ggplot(NY_Discharge, aes(x = Date, y = MeanDischarge)) +
  scale_y_log10() +
  geom_point(color = "turquoise4", size = 0.7) +
  geom_smooth(method = lm, color = "black") +
  ylab("Daily Discharge (cfs)") +
  labs(title = paste("Daily Discharge During Hurricane Seasons (1990-2021)"), subtitle = paste("Cold Spring Harbor, New York"))

