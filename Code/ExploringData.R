require(tidyverse)
require(dplyr)
require(lubridate)

florida <- read.csv("./Data/Raw/Discharge_NorthCanal_FL_Raw3.csv", stringsAsFactors = T)

florida_clean <- florida %>%
  mutate(Date = mdy(datetime)) %>%
  mutate(Discharge = X30943_00060) %>%
  mutate(State = "Florida") %>%
  select(State, site_no, Date, Discharge)

florida_hurricane <- florida_clean %>%
  mutate(month = month(Date)) %>%
  filter(month >= 6 & month <= 10) %>%
  select(1:4)

  


