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
**Air Tube-20180928T185037Z-001.zip** – data from personal sensors with PM10 and PM2.5 and weather measurements (whole Bulgaria)     

**EEA Data-20180928T184849Z-001.zip**  – data from 6 official stations in Sofia with PM10 measures      

**METEO-data-20180928T185127Z-001.zip** – historical meteorological data from Sofia    

**TOPO-DATA-20180928T185225Z-001.zip** – topological data for points around Sofia     


##	1. Business Understanding
Air pollution is one of the most serious problems in the world. It refers to the contamination of the atmosphere by harmful chemicals or biological materials. To solve the problem of air pollution, it is necessary to understand the issues and look for ways to counter it.

Air pollution can cause both short-term and long-term health effects. Air pollution causes damage to crops, animals, forests, and bodies of water. It also contributes to the depletion of the ozone layer, which protects the Earth from the sun's UV rays.

In Bulgaria, EEA collects air pollution statistics. It's important to study these statistics because they show how polluted the air has become in various places around the country.

In Sofia, air pollution norms were exceeded a lot of times in the past few years. During the day with the worst air pollution in Sofia the norm was exceeded six times over. The two main causes for the air pollution are believed to be solid fuel heating and motor vehicle traffic.

The main objectives of this study are to predict the air pollution in Sofia for the next 24 hour period as well as the probability that the EU air quality limit of 50 µg/m3 average for the day will be exceeded.


##	2. Data Understanding

### Official stations – EEA_DATA

We were provided with PM10 daily measurements from 5 stations in Sofia for the time years 2013-2018 from 5 stations in Sofia. Unfortunately, the data was quite unconsistent. Some of the uncostistencies were:    
- for station #9484 we have measurements for only the first 3 years and for station #60881 only for 2018. We chose to exclude these stations in order to avoid additional bias to the dataset.     
- for 2013, 2014 and 2015 the granularity of observations is one per day, whereas for the subsequent years it becomes per hour. Thus, there anywhere between 2 and 48 observations each day. We aggredated the hourly observations by gathering the minimum, maximum, mean and variance of the observations of each station's daily observations
- we have on average around 15 missing days for the years 2013 – 2016. We filled the missing values using linear interpolation.      
- for stations #9421, #9572, #9616, #9642 observations for 2017 year start at November 27, totally missing the values from the previous days. For year 2018, observed days are up to September 14. A possible solution is to take years 2013-2016 as training set and 2017-2018 as a test set.      

Daily mean values of PM vs the number of observations per day for station **#9421** can be explored in the following graphics:    

--  Graphics im EEAimages 2013-2018

### Personal sensors - Air Tube 

#### Visualization on PM10 on the map of Sofia

The following visualization shows the stations in a radius around the center of Sofia. This visualization depicts PM10 atmospheric measurements, and the colors are the following:       
	- no color: there are no measured values
	- green: there is data with low values
	- yellow: there are values with average values
	- red: there are values which are really high

Chart DU\_200 01 below depicts all days that exceed the EU air quality limit of 50 µg/m3 of PM10 concentration in red.

Chart DU\_0200 01 - PM10 Pollution Above Treshold of 50 µg/m3.

![2. Data Understanding/DU_410-pm10-heat-map-above-threshold.gif][Du_0201_01]

Chart DU\_0200 02 - Sofia PM10 Pollution Heat Map Throughout Time

![2. Data Understanding/DU_400-pm10-heat-map-over-time.gif][Du_0201_02]


### METEOROLOGICAL DATA from SOFIA AIRPORT (LBSF) - METEO-data

#### About the dataset
The supplied dataset contains a README file, where the columns are explained.

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

The custom stations are located all over Bulgaria. To select only the relevat stations, we decode each station's geohash to geographic coordinates. Since the dataset contains weather stations from the entire country, we draw an imaginary circle with radius spanning from the center of Sofia to German village and select only the stations whoose coordinates lie within the circle. 

### Data aggregation

After having analysed each dataset individually, we move on to combining the data into a single data set, which can be fed into a variety of models. We opt not to differenciate between official stations and personal sensors in order to attain the ability to train the same types of models on both types of stations at the same time. All data is aggregated to the same format of a unique (station_id, date) tuple. Whereas the official sensors have their own unique ID numbers as described above, the personal personal sensors only have unique geohashes. To correct this discrepancy, we give each unique geohash in the Air Tube dataset a unique surogate ID.

The measurements in some stations are made daily and others are hourly - the granulaity is one measurement per hour. We resolve this conflict by aggregating data by minimum, maximum, average and standard deviation. Official stations did not record weather data, so we merged their data with the weather data from the Sofia Airport meteorological station.


### Feture engineering 

We use the dates of the records to extract additional time information such as whether the corresponding day is a weekday or a weeked day, wether it falls on an official public holiday in Bulgaria and wether it falls on a **long weekend** (between a holiday and a weekend). We expenct that a lot of people leave Sofia during holidays/long weekends and therefore PM levels decrease. 


### Data validation

Our allgorithm for validating the results from the custom station is the following:
1. For every custom station, compute the distance from it to all official stations
2. Filter only the stations that have an official station with a distance in the first quartile. 
3. Select the nearest official station. 
3. Check if the PM10 reading from the sensor is **no more than 3 times higher** than that from the official: 
	- if it falls in the limit - take the data as valid; 
	- if not - replace with that of the official station. 


### Data enrichment

We add missing  historical values of  dataset using linear interpolation. We also attempt to add traffic data to our data set, but could not find relative information for the time period 2013-2018.


##	4. Modelling

The main challenge of the case is that we have two dimensions for the observations - time and geographical position. Having more than 650 sensors, a traditional Time Series approach such as ARIMA cannot properly model the data. One possible solution is to build 650 separate models predicting the average PM10 values for the following day for every station; then we aggregate the using ensemble techniques such as voting in order to gather a single prediction for Sofia. Alternatively, we can employ a different type of model which can incorporate all weather station data into a single predictive model.

###	Model Baseline
A baseline model is useful to determine how much a more advanced model can contribute to improving the overall prediction accuracy. The exact type of model depends on which approach to aggregating the model is used.

Traditional time series models reference a "naive" model. The simplest approach is to create a random walk, which translates to an ARIMA(0, 1, 0) with an optional drift component. Seasonal ARIMA models can be modelled similarly by employing an ARIMA(0, 0, 0)(0, 1, 0)m where m is the seasonal component.

Models, which incorporate spatial and temporal components into a single prediction, do not allow a simple baseline to be computed. For these models, we only evaluate the model accuracy as per the evaluation metrics, mentioned in section 5. Evaluation.

###	Ensemble approach
The ensemble approach requires that the dataset be split into separate datasets for each unique measurement station. We then compute different time series models for comparison purposes. The end result is that for each model type we need the same enumber of models as there are valid stations in the dataset. Time series models include the following:

1. Naive model - random walk
2. ARIMA - Auto-Regressive Integrated Moving Average
3. ARIMAX - Auto-Regressive Integrated Moving Average with external non-temporal variables

To arrive at a single prediction for the entire city of Sofia we then aggregate the predictions of all models based on a simple arithmetic mean of the predictied values. One possible encancement of the ensemble is to apply weights to each individual model that are proportional to that model's overall accuracy. For example, we can divide the current model's Root Mean-Squared Error by the sum of Root Mean-Squared Errors of all individual models.

###	Single-model approach
We can avoid the hurdle of aggregating individual models by applying a different model type that incorporates both spacial and temporal data into its algorithm. Traditional statistics models that allow this revolve around panel regression, specifically using Fixed effects or Random effects models. There  each individual station is tracked over time and temporal observations are compared to an average value of that specific station over time. The final result arrives at a single set of regressor weights that are valid for all stations at the same time.

### 	Simple linear regression
We also fit a simple linear regression. Further data transformation is performed. We transforme datetime values to their sine and cosine equivalents. By this we attempt to control for seasonality in the results. We also introduce Year as a variable. Further meteorological data is used to model the PM10 avearage values. The variables used are average temperature, average precipitation, average surface pressure, and average wind speed. The model thus achieves an adjusted R^2 0.2818.

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

### Getting wether forecasts
If our model matures to production, we can use [AccuWether's API](https://developer.accuweather.com/user/) to get daily weather forecast data for the next 24 hours. 

### Retraining the model
After the model has been in use for some time, it can be retrained with new data every 3 months, so that it can be monitored and validated over time.

### Future improvents
Articles for similar cases for other big cities as **Madrid, Spain**[3] and **Beijing, China** show that it is useful to add traffic information as predictive values in the model. Right now, we could not find publicly available historical data for traffic in Sofia. We found data for the [number of daily vehicle accidents in Sofia](http://opendata.yurukov.net/kat/en), which can be used as an approximation for the traffic intensity, but unfortunately it is only available for the years 2013-2014.

Our solution for the problem of missing traffic data will be to start gathering hourly information for the traffic in several regoins in Sofia, using a publicly available API such as the [Google Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix/start). 

##	7. Documentation

### Literature 

[1] Air Pollution: Understanding the Problem and Ways to Help Solve It ,  https://www.air-n-water.com/air-pollution.htm     
[2] CHRISTOPHER NICASTRO, Bulgaria’s Air Pollution Problem: Could it get any Worse?, https://zerowasteeurope.eu/2018/01/bulgaria-air-pollution/     
[3] Dan Wei, Predicting air pollution level in a specific city, http://cs229.stanford.edu/proj2014/Dan%20Wei,%20Predicting%20air%20pollution%20level%20in%20a%20specific%20city.pdf     
[4] Predicting Air Pollution in Madrid, https://blog.bigml.com/2018/03/13/predicting-air-pollution-in-madrid/      

[Du_0201_01]: https://raw.githubusercontent.com/Bugzey/Team-Midas/master/2.%20Data%20Understanding/DU_410-pm10-heat-map-above-threshold.gif
[Du_0201_02]: https://raw.githubusercontent.com/Bugzey/Team-Midas/master/2.%20Data%20Understanding/DU_400-pm10-heat-map-over-time.gif

