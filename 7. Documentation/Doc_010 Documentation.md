#	Telelink Case Solution
Team Dimas

## Members

	- apetkov
	- desinik
	- rdimitrov
	- melania-berbatova
	- vrategov 


##	Content


##	Introduction


##	0. Data

Air Tube-20180928T185037Z-001.zip – data from personal sensors with PM10 and PM2.5 and weather measurements (whole Bulgaria)     
EEA Data-20180928T184849Z-001.zip  – data from 6 official stations in Sofia with PM10 measures      
METEO-data-20180928T185127Z-001.zip – historical meteorological data from Sofia    
TOPO-DATA-20180928T185225Z-001.zip – topological data for points around Sofia     


##	1. Business Understanding
Air pollution is one of the most serious problems in the world. It refers to the contamination of the atmosphere by harmful chemicals or biological materials. To solve the problem of air pollution, it's necessary to understand the issues and look for ways to counter it.

Air pollution can cause health effects in both short-term and long-term health effects.

Air pollution causes damage to crops, animals, forests, and bodies of water. It also contributes to the depletion of the ozone layer, which protects the Earth from the sun's UV rays.
In Bulgaria, EEA collects air pollution statistics. It's important to study these statistics because they show how polluted the air has become in various places around the country.

In Sofia, air pollution norms were exceeded a lot of times in the past few years. The day with the worst air pollution in Sofia the norm was exceeded six times over. The two main reasons for the air pollution are believed to be solid fuel heating and motor vehicle traffic.

The main objectives are to predict the air pollution in Sofia for the next 24 hour period and to predict the chance of exceedance of 50 µg/m3 average for the day (EU air quality limit).


##	2. Data Understanding

### Official stations – EEA_DATA

We were provided with PM10 daily measurements from 5 stations in Sofia for the time years 2013-2018 from 5 stations in Sofia. Unfortunately, the data was quite unconsistent. Some of the uncostistencies were:    
– for station with #9484 we have measurements for only the first 3 years and for station #60881 only for 2018. We desided to exclude these stations, so not to add additional bias to the dataset.     
– for 2013, 2014 and 2015 the granularity of observations was per day, whereas for the new years it was per hour. There were between 2 and 48 observations per day. We aggredated the hourly observations gathering the minimum, maximum, mean and  variance of the observations per day per one station      
– we had on average around 15 missing days for years 2013 – 2016. We filled the missing values using linear interpolation.      
– for stations #9421, #9572, #9616, #9642 observations for 2017 year started at November 27, totally missing the values from the previous days. For year 2018, observed day are up to September 14. A possible solution is to take years 2013-2016 as training set and 2017-2018 as a test set.      

Daily mean values of PM vs number of observations per day for station **#9421** can be explored in the following graphics:    

--  Graphics im EEAimages 2013-2018

### Personal sensors - Air Tube 

##### Visualization on PM10 on the map of Sofia

The following visualization is showing the stations in a radius around the center of Sofia. This visualization is for PM10 and the colors are the following:       
	 - no color: there are any measured values       
	 - green: there is data with low values       
	 - yellow: there are values with middle values      
	 - red: there are values, which are really high         

After using the threshold of 50 µg/m3, the red color is equivalent to every value, which exceeds the EU air quality limit. See in Chart DU\_200 01 below.

Chart DU\_0200 01 - PM10 Pollution Above Treshold of 50 µg/m3.

![2. Data Understanding/DU_410-pm10-heat-map-above-threshold.gif][Du_0201_01]

Chart DU\_0200 02 - Sofia PM10 Pollution Heat Map Throughout Time

![2. Data Understanding/DU_400-pm10-heat-map-over-time.gif][Du_0201_02]


### METEOROLOGICAL DATA from SOFIA AIRPORT (LBSF) - METEO-data

About METEO-data
There is a README file, where the columns are explained.
The data is from 1.Jan. 2012 until 17.Sep.2018. All of the missing values (-9999) are in the data for Daily minimum and maximum precipitation amount, so it will not be used for the prediction. 
Daily temperature:
DU_270 TEMPAVG.svg	
DU_280 TEMPMAX.svg	
DU_290 TEMPMIN.svg         	
Daily dew point temperature
DU_150 DTAVG.svg	
DU_160 DTMAX.svg	
DU_170 DTMIN.svg      	
Daily relative humidity
DU_180 HUMAVG.svg	
DU_190 HUMMAX.svg	
DU_200 HUMMIN.svg           	
Daily wind speed
DU_300 WINDAVG.svg	
DU_310 WINDMAX.svg	
DU_320 WINMIN.svg         
Daily surface pressure
DU_240 PRESAVG.svg	
DU_250 PRESMAX.svg	
DU_260 PRESMIN.svg           		
Daily average visibility
DU_340 VIS.svg

##	3. Data Preparation

### Data selection

The custom stations were located all over Bulgaria. To select only the relevat stations, we decoded each station's geohash to coordinates, we drove an imaginary circle with radius from the center of Sofia to German village and selected only the stations  which coordinates were falling into the circle. 

### Data aggregation

We desided to not differenciate between official stations and personal sensors. All data was aggregated to the same format of unique (station_id, date) tuple. Personal sensors were given surogate ids.       
As for some stations the measurements were daily and for other hourly, where the granulaity were per hour, we aggregated data by minimum, maximum, average and standard deviation.       
Official stations did not have weather data, so we merged their data with the weather data from the Sofia Airport meteostattion. 


### Feture engineering 

We used the dates of the records to extract additional time information as if the corresponding day is a weekday or weeked day, if it falls in the official holiday calendar and weather falls into a **long weekend** (between a holiday and a weekend). We expenct that a lot of people leave Sofia during holidays/long weekends and PM levels decrease. 

### Data validation

Our allgorithm for validating the results from the custom station was:    
1. For every custom station, computing the distance from it to all official station
2. Filter only the stations that have an official staton with distance in the first quartile. 
3. Select the nearest official station. 
3. Chech if the PM10 from the sensor is **no more than 3 times bogger** than the official one: 
- if it falls in the limit - take the data ai valid; 
- if not - replace with the official stations. 


### Data enrichment.

We added missing  historical values of  dataset using linear interpolation. 
We also looked if we can add traffic data to our data set, but was unable to find relative information for the time period 2013-2018).


##	4. Modelling

The main challenge of the case is that we have two dimensions of the observations - time and geographical position. Having more than 650 sensors, a traditional Time Series approach such as ARIMA cannot properly model the data. One possible solution can be to build 650models predicting the average PM10 values for the following day for every station and then aggregate the using ensemble techniques such as voting to gather a total prediction for Sofia. Alternatively, we can employ a different type of model which can incorporate all weather station data into a single predictive model.

###	Model Baseline
A baseline model is useful to determine how much a more advanced model can contribute to improving the overall prediction accuracy. The exact type of model dpeends on which approach to aggregating the model is used.

Traditional time series models can make use of a "naive" model. The simplest approach is to create a random walk model, which translates to an ARIMA(0, 1, 0) with an optional drift component. Seasonal ARIMA models can be modelled similarly by employing an ARIMA(0, 0, 0)(0, 1, 0)m where m is the seasonal component.

MOdels, which incorporate spatial and temporal components into a single prediction, do allow a simple baseline to be computed. For these models, we only evaluate the model accuracy as per the evaluation metrics, mentioned in section 5. Evaluation.

###	Ensemble approach
The ensemble approach requires that the dataset be split into separate datasets for each unique measurement station. We then compute different time series models for comparison purposes. The end result is that for each model type we need the sam enumber of models as there are valid stations in the dataset. Time series models include the following:

1. Naive model - random walk
2. ARIMA - Auto-Regressive Integrated Moving Average
3. ARIMAX - Auto-Regressive Integrated Moving Average with external non-temporal variables

To arrive at a single prediction for the entire city of Sofia we then aggregate the predictions of all models based on a simple arithmetic mean of the predictied values. One possible encancement of the ensemble is to apply weights to each individual model that are proportional to that model's overall accuracy. For example, we can divide the current model's Root Mean-Squared Error by the sum of Root Mean-Squared Errors of all individual models.

###	Single-model approach
We can avoid the hurdle of aggregating individual models by applying a different model type that incorporates both spacial and temporal data into its algorithm. Traditional statistics models that allow this revolve around panel regression, specifically using Fixed effects or Random effects models, where each individual station is tracked over time and temporal observations are compared to an average value of that specific station over time. The final result arrives at a single set of regressor weights that are valid for all stations at the same time.


##	5. Evaluation

We split the data into a training set and a testing set.
For the testing data set we use a fixed period (e.g. 20%) of the most recent time series data for each station.

For the linear regression model, R-Squared and Root-Mean-Squared-Error are used as metrics to evaluate the model.

For the time series prediction models, the following metrics are used for evalution of the model:
- MAE - Mean Absolute Error
- MAPE - Mean Absolute Percentage Error
- MASE - Mean Absolute Scaled Error
- RMSE - Root Mean Squared Error

##	6. Deployment

### Getting wether forecast

If our model gets into production, we can use [AccuWether's API](https://developer.accuweather.com/user/) to get daily weather forecast data for the next 24 hours. Here is the data we can get from the API:

### Retraining the model

Once the model is into production, it can be retrain with new data every 3 months, so it can be monitored and validated over time.

### Future improvents

Articles for similar cases for other big cities as **Madrid, Spain**[3] and **Beijing, China** show that it is useful to add traffic information as predictive values in the model. Right now, we could not find publicly available historical data for traffic in Sofia. We found data for the [number of daily vehicle accidents in Sofia](http://opendata.yurukov.net/kat/en), which can be used as an approximation for the traffic, but unfortunately it is only available for years 203-2014.

Our solution for the problem of the lack of the traffic data will be to start  gathering hourly information for the traffic in several regoins in Sofia, using the [Google Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix/start). 

##	7. Documentation

### Literature 

[1] Air Pollution: Understanding the Problem and Ways to Help Solve It ,  https://www.air-n-water.com/air-pollution.htm     
[2] CHRISTOPHER NICASTRO, Bulgaria’s Air Pollution Problem: Could it get any Worse?, https://zerowasteeurope.eu/2018/01/bulgaria-air-pollution/     
[3] Dan Wei, Predicting air pollution level in a specific city, http://cs229.stanford.edu/proj2014/Dan%20Wei,%20Predicting%20air%20pollution%20level%20in%20a%20specific%20city.pdf     
[4] Predicting Air Pollution in Madrid, https://blog.bigml.com/2018/03/13/predicting-air-pollution-in-madrid/      

[Du_0201_01]: https://raw.githubusercontent.com/Bugzey/Team-Midas/master/2.%20Data%20Understanding/DU_410-pm10-heat-map-above-threshold.gif
[Du_0201_02]: https://raw.githubusercontent.com/Bugzey/Team-Midas/master/2.%20Data%20Understanding/DU_400-pm10-heat-map-over-time.gif

