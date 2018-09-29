## Interests

Melania:

    - Gather traffic data
    - Topological map

Anton:

    - Visualize geographic data

Rado:

    - Gather and analyze holiday data
    - General project management
    - Documentation

Desi:

    - Documentation
    - Add more weather data from new weather stations

Ivan:

    - Data exploration and understanding


## Tasks

- Enrich data (can be done in the end, when we have processed all available data):
    - [ ] ~~Add traffic data~~
    - [X] Engineer new feature using data for national holidays. People travel with cars before and after holidays.
    - [ ] ~~Add more weather data from different stations.~~ And possibly inrepolate measurements for missing locations (e.g. we have temperature data for Druzhba and Lyulin and we interpolate the temperature for Sofia's center).
        - API: https://darksky.net/dev

- Visualization:
    - [ ] Geographic data:
        - [X] Visualize hotspots of PM10. Can we find special locations which contribute most for the PM10 pollution.
        - [ ] Visualize hotspots of meteorologic data. For example, there may be some locations with a lot of humidity or high pressure.
			- http://lmgtfy.com/?q=getis+ord
    - [ ] Time Series visualization in order to see how these metrics have changed throughout time.

- [ ] Business Understanding - description

- [ ] Data Preparation
	- [X] Map geohashes to coordinates
	- [ ] Combine datasets
	- [ ] Clean datasets - missing values, outliers, decide whether to drop bad stations

- [ ] Modelling
	- [ ] Baseline model 
		- Time series: naive model (daily, weekly)
		- Cross-section: Ordinary Least Squares, Logistic regression
	- [ ] Time series model (ARIMA)
	- [ ] Time series with external variables (ARIMAX)
	- [ ] Machine learning
		- Trees
		- Artificial neural network (e.g. R library forecast, function nnetar())

- [ ] Evaluation
	- [ ] Choose evaluation metrics
	- [ ] Compare all models

- [ ] Deployment
	- [ ] Describe how implement the model
	- [ ] Describe data and modelling shortcomings

- [ ] Documentation
	- [ ] Full documentation
	- [ ] Article submitted in the DSS website


