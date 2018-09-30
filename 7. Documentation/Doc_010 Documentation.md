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



### Data from sensors 

### Personal sensors - Air Tube 

##### Visualization on PM10 on the map of Sofia

The following visualization is showing the stations in a radius around the center of Sofia. This visualization is for PM10 and the colors are the following:       
	 - no color: there are any measured values       
	 - green: there is data with low values       
	 - yellow: there are values with middle values      
	 - red: there are values, which are really high         
After using the threshold of 50 µg/m3, the red color is equivalent to every value, which exceeds the EU air quality limit.


##	3. Data Preparation

### Data aggregation

All data was aggregated to the same format of unique (station_id, date) tuple. Personal sensors were given surogate ids.

### Data validation

We used data from the official stations’ particular manner’s measurements to validate sensor’s data.

### Data cleaning

### Data enriching

We added missing  historical values of  dataset using linear interpolation.

We also looked if we can add traffic data to our data set, but was unable to find relative information for the time period 2013-2018).


##	4. Modelling


##	5. Evaluation

### Getting wether forecast

If our model gets into production, we can use [AccuWether's API](https://developer.accuweather.com/user/) to get daily weather forecast data for the next 24 hours. Here is the data we can get from the API:

### Retraining the model

Once the model is into production, it can be retrain with new data every 3 months, so it can be monitored and validated over time.

### Future improvents

Articles for similar cases for other big cities as **Madrid, Spain**[3] and **Beijing, China** show that it is useful to add traffic information as predictive values in the model. Right now, we could not find publicly available historical data for traffic in Sofia. We found data for the [number of daily vehicle accidents in Sofia](http://opendata.yurukov.net/kat/en), which can be used as an approximation for the traffic, but unfortunately it is only available for years 203-2014.

Our solution for the problem of the lack of the traffic data will be to start  gathering hourly information for the traffic in several regoins in Sofia, using the Google [Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix/start). 

##	6. Deployment


##	7. Documentation

### Literature 

[1] Air Pollution: Understanding the Problem and Ways to Help Solve It ,  https://www.air-n-water.com/air-pollution.htm     
[2] CHRISTOPHER NICASTRO, Bulgaria’s Air Pollution Problem: Could it get any Worse?, https://zerowasteeurope.eu/2018/01/bulgaria-air-pollution/     
[1] Dan Wei, Predicting air pollution level in a specific city, http://cs229.stanford.edu/proj2014/Dan%20Wei,%20Predicting%20air%20pollution%20level%20in%20a%20specific%20city.pdf     
[2] Predicting Air Pollution in Madrid, https://blog.bigml.com/2018/03/13/predicting-air-pollution-in-madrid/      

