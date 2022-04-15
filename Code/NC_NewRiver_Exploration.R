# initial data visualiation of discharge
DailyDischarge.Plot <- 
  ggplot(NewRiver.Daily.Discharge.Clean, aes(Date, MeanDailyDischarge_cfs)) +
  geom_point(color = "forestgreen") +
  geom_smooth(method = "lm", color = "black") +
  labs(x = "Date", y = "Mean Daily Discharge (cfs)",
       title = "Mean Daily Discharge During Hurrcane Seasons (1990-2021)", 
       subtitle = "New River, North Carolina") +
  theme(plot.title=element_text(hjust=0.5)) +
  theme(plot.subtitle=element_text(hjust=0.5)) +
  scale_y_log10()
DailyDischarge.Plot