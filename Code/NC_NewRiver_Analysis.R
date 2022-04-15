# creating daily discharge time series
NewRiver.Daily.Discharge.ts <- ts(NewRiver.Daily.Discharge.Clean$MeanDailyDischarge_cfs,
                                  start = c(1990, 06, 01), frequency = 153)

# decomposing daily time series
Daily.Discharge.decomp <- stl(NewRiver.Daily.Discharge.ts, s.window = "periodic")
plot(Daily.Discharge.decomp)

# adding components into a dataframe, removing seasonal component
Daily.Discharge.Components <- as.data.frame(Daily.Discharge.decomp$time.series[,2:3])

# adding trend and remainder for analysis
NonSeasonalDischarge.Daily <- mutate(Daily.Discharge.Components,
                                     Seasonality_Removed = Daily.Discharge.Components$trend +
                                       Daily.Discharge.Components$remainder)

# creating non-seasonal time series
NonSeasonal.DailyDischarge.ts <- ts(NonSeasonalDischarge.Daily$Seasonality_Removed,
                                    start = c(1990, 06, 01), frequency = 153)

# adding date column to nonseasonal df
NonSeasonalDischarge.Daily <- NonSeasonalDischarge.Daily %>% 
  mutate(Date = NewRiver.Daily.Discharge.Clean$Date)

# creating nonseasonal plot
NonSeasonal.Plot <- ggplot(NonSeasonalDischarge.Daily, aes(Date, Seasonality_Removed)) +
  geom_point(color = "forestgreen", size = 0.6) +
  scale_y_log10() +
  geom_smooth(method = "lm", color = "black") +
  labs(x = "Date", y = "Non-Seasonal Daily Discharge (cfs)", 
       title = "Non-Seasonal Mean Daily Discharge During Hurricane Seasons",
       subtitle = "New River, North Carolina") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 year") +
  theme(axis.text.x = element_text(angle = 90)) 
NonSeasonal.Plot

# running Mann Kendall on time series with seasonality removed
MannKendall(NonSeasonal.DailyDischarge.ts)