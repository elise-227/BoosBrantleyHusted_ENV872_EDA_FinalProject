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
  select(Agency, SiteNumber, MeanDischarge, Month, Date, Year) %>%
  drop_na() %>%
  filter(Month > 5, Month < 11,
         #Year >= 90)
         Date >= "1990-06-01")
view(NY_Discharge.processed)

#log mean discharge
NY_Discharge.processed$LogDischarge = log(NY_Discharge.processed$MeanDischarge)


#Daily Discharge Plot logged
ggplot(NY_Discharge.processed, aes(x = Date, y = LogDischarge)) +
  geom_point(color = "blue", size = 0.7) +
  geom_smooth(method = lm, color = "black") +
  ylab("Daily Discharge (cfs)") +
  labs(title = paste("Daily Discharge During Hurricane Seasons (1990-2021)"), subtitle = paste("Cold Spring Harbor, New York")) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 year") +
  theme(axis.text.x = element_text(angle = 90)) 
  


#NY Daily Discharge time-series
NY_DailyDischarge.ts <- ts(NY_Discharge.processed$LogDischarge, start = c(1990,01), frequency = 153)
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


#Nonseasonal MannKendall
NY_Components <- as.data.frame(NY_DailyDischarge.decompose$time.series[,2:3])
view(NY_Components)

NY_Components <- mutate(NY_Components,
                        Observed = NY_Discharge.processed$MeanDischarge,
                        Date = NY_Discharge.processed$Date)

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


NY_NonSeasonal.Plot <- autoplot(NY_Nonseasonal.ts) +
  scale_y_log10() +
  labs(x = "Date", y = "Non-Seasonal Daily Discharge (cfs)", 
       title = "Non-Seasonal Mean Daily Discharge During Hurricane Seasons (1990-2021)", 
       subtitle = "Cold Spring Harbor, New York") 
  #geom_smooth(method = "lm")
print(NY_NonSeasonal.Plot)
 
# running Mann Kendall on time series with seasonality removed
MannKendall(NonSeasonal.DailyDischarge.ts)

