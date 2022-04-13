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
NY_AnnualPeakDischarge <- read.csv("Data/Raw/NYAnnualPeakFlowDischarge.csv", stringsAsFactors = T)

#Format Date
NY_Discharge$Date <- as.Date(NY_Discharge$Date, format = "%m/%d/%Y")
NY_AnnualPeakDischarge$Date <- as.Date(NY_AnnualPeakDischarge$Date, format = "%m/%d/%Y")

#Set Theme
my_theme <- theme_classic(base_size = 14) +
  theme(axis.text = element_text(color = "black"), 
        legend.position = "bottom", legend.text=element_text(size=8), 
        legend.title=element_text(size=10), panel.background = element_rect(fill = "gray95"), 
        panel.grid.major = element_line(size = 0.6, linetype = 'solid', colour = "white"))

theme_set(my_theme)

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



#saving processed file as a csv
write.csv(NY_Discharge.processed, "./Data/Processed/NY_DischargeData_Processed", row.names = FALSE)


#Initial Visualization of Data: Daily Discharge Plot (logged)
ggplot(NY_Discharge.processed, aes(x = Date, y = MeanDischarge)) +
  scale_y_log10() +
  geom_point(color = "turquoise4", size = 0.7) +
  geom_smooth(method = lm, color = "black") +
  ylab("Daily Discharge (cfs)") +
  labs(title = paste("Daily Discharge During Hurricane Seasons (1990-2021)"), subtitle = paste("Cold Spring Harbor, New York")) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 year") +
  theme(axis.text.x = element_text(angle = 90)) 
  



#NY Daily Discharge time-series
NY_DailyDischarge.ts <- ts(NY_Discharge.processed$MeanDischarge, start = c(1990,01), frequency = 153)
head(NY_DailyDischarge.ts, 10)

#Decompose
NY_DailyDischarge.decompose <- stl(NY_DailyDischarge.ts, s.window = "periodic")
plot(NY_DailyDischarge.decompose)


--------------------------------------------------------------------------------------
#Messing with Interactive time-series functions
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
--------------------------------------------------------------------------------------
  

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


#trying to create a plot for the ts but not working! (I'll try ggplot instead below as well)
#autoplot version
NY_NonSeasonal.Plot1 <- autoplot(NY_Nonseasonal.ts) +
  scale_y_log10() +
  labs(x = "Date", y = "Non-Seasonal Daily Discharge (cfs)", 
       title = "Non-Seasonal Mean Daily Discharge During Hurricane Seasons (1990-2021)", 
       subtitle = "Cold Spring Harbor, New York") +
  geom_smooth(method = "lm")
print(NY_NonSeasonal.Plot1)
 
#ggplot version (working)
NY_NonSeasonal.Plot2 <- ggplot(NY_Combine_Nonseasonal, aes(x = Date, y = Nonseasonal)) +
  scale_y_log10() +
  geom_point(color = "turquoise4", size = 0.6) +
  labs(x = "Date", y = "Non-Seasonal Daily Discharge (cfs)", 
       title = "Non-Seasonal Mean Daily Discharge During Hurricane Seasons", 
       subtitle = "Cold Spring Harbor, New York") +
  geom_smooth(method = "lm", color = "black") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 year") +
  theme(axis.text.x = element_text(angle = 90)) 
                               
print(NY_NonSeasonal.Plot2)

