#	
#	M_010 Statistical Models.R
#	
#	Attempts to model particulate matter concentrations via traditional statistical models
#	

rm(list = ls())
dependencies = list("forecast")

sapply(
	dependencies,
	function(dep)
	{
		if (!require(dep, character.only = TRUE)) {
			install.packages(dep)
			require(dep, character.only = TRUE)
		} else {
			require(dep, character.only = TRUE)
		}
	}
)

project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

input_data_file = "0. Data/clean_pm10.csv"

#	Get current data
data_analysis_all = read.csv(input_data_file)

#	Apply some cleaning (wherever data is dirty) - For each model type separately
station_ids = unique(data_analysis_all[, "station"])

data_analysis_list = lapply(
	station_ids,
	function(cur_station)
	{
		df = data_analysis_all[data_analysis_all[, "station"] == cur_station, ]
		df = df[order(df[, "time"]), ]
		return(df)
	}
)

#	Per-station data prep

#	Modelling
#		1. Per-station naive model + ENSEMBLE prediction
#		2. Per-station ARIMA via auto.arima()
#		3. Random / Fixed effects
#		4. NNETAR

#	1. Per-station naive model
model_naive = lapply(
	data_analysis_list,
	function(df)
	{
		target_var = df[, "p1_mean"]
		dates = df[, "time"]
		na_dates = is.na(target_var)
		
	}
)

#	Define target var

#	Interpolate missing vars

#	Set start and end time of predictions