# getting directory
getwd()

# loading packages
library(ggplot2)
library(tidyverse)
library(lubridate)
library(dplyr)
library(zoo)
library(Kendall)
library(ggfortify)
library(stats)

# loading in data
NewRiver.Discharge.RAW <- read.csv("./Data/Raw/NC_Discharge_NewRiver_RAW.csv")

# setting date column as date
NewRiver.Discharge.RAW$Date <- as.Date(NewRiver.Discharge.RAW$datetime, format = '%m/%d/%y')

# initial tidying of dataset
NewRiver.Discharge.RAW <- NewRiver.Discharge.RAW[-c(1), ] # removing non-data row

NewRiver.Discharge.PROC <- NewRiver.Discharge.RAW %>% 
  select(agency_cd, site_no, 
         X89345_00060, Date) #selecting necessary columns

colnames(NewRiver.Discharge.PROC) <- c("Agency", "Site_No",
                                       "Discharge_cfs", "Date") # changing column names

# setting discharge column as numeric
NewRiver.Discharge.PROC$Discharge_cfs <- as.numeric(NewRiver.Discharge.PROC$Discharge_cfs)

NewRiver.Discharge.PROC <- NewRiver.Discharge.PROC %>% 
  group_by(Date) %>%  # grouping by date
  mutate(Year = year(Date), # creating year column
         Month = month(Date), # creating month column
         Day = day(Date)) %>% # creating day column
  filter(Year >= 1990) %>% # filtering for data 1990 or later
  filter(Month > 5 & Month < 11) # filtering for data in hurricane season

# saving processd file as csv
write.csv(NewRiver.Discharge.PROC, "./Data/Processed/NC_Discharge_NewRiver_PROC.csv", row.names = FALSE)

# filling missing data with linear interpolation
NewRiver.Discharge.Clean <-
  NewRiver.Discharge.PROC %>%
  mutate(Discharge_cfs_Clean = zoo::na.approx(Discharge_cfs))

# setting clean column as numeric
NewRiver.Discharge.Clean$Discharge_cfs_Clean <- as.numeric(NewRiver.Discharge.Clean$Discharge_cfs_Clean)

# creating daily discharge dataset
NewRiver.Daily.Discharge.Clean <- NewRiver.Discharge.Clean %>% 
  group_by(Date) %>% 
  dplyr::summarize(MeanDailyDischarge_cfs = 
                     mean(Discharge_cfs_Clean)) %>%  #daily mean discharge
  mutate(Year = year(Date), # creating year column
         Month = month(Date), # creating month column
         Day = day(Date)) # creating day column