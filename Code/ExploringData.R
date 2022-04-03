require(tidyverse)
require(dplyr)
require(lubridate)

florida <- read.csv("./Data/Raw/Discharge_NorthCanal_FL_Raw2.csv", stringsAsFactors = T)

florida_clean <- florida %>%
  as.Date(datetime, "%m/%d/%y")

  

