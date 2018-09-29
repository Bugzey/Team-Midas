##	Folder: Air Tube
Files: several csv-s with identical structure.

Granularity: hourly, for each measurement station

* date
* geohash
* p1 - whole number
* p2 - whole number
* humidity
* pressure

##	Folder Meteo-Data
The data is scraped from Wunderground. Has its own Readme file with a description.

Meteorological data may have a lot of missing values.

Granularity: year, month, day, all in the same city - Sofia Airport.

Idea: get additional measurements via an API - e.g. DarkSkyAPI


##	Folder: EEA Data
Data about actual particulate matter concentrations. Has its own Readme.

Contains the main target variable - PM10 and PM2.5 concentration.

Granularity: daily data, for each weather station.


##	Folder: Topo Data
Topological data - lat, lon, elevation. No time component (hopefully), 196 points


