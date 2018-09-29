#	
#	DP_020 Data Merge.R
#	
#	Merge all processed datasets into one analysis dataset

#
#	Data and workspace
#	

rm(list = ls())
project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

data_dir = "0. Data"
data_understanding_dir = "2. Data Understanding"

#	Which are the csv-s?
date_dimension_file = "0. Data/date_dimension.csv"
datafile1 <- "0. Data/Air Tube/data_bg_2017.csv"
datafile2 <- "0. Data/Air Tube/data_bg_2018.csv"

geohash_1 = "0. Data/geohash_mapping_sofia_2017_unique.csv"
geohash_2 = "0. Data/geohash_mapping_sofia_2018_unique.csv"

eea_file = "0. Data/EEA Data-20180928T184849Z-001/EEA Data/eea_final.csv"

meteo_file = "0. Data/METEO-data/lbsf_20120101-20180917_IP.csv"

#	Load the CSV-s
date_dimension = read.csv(file = date_dimension_file)

air_tube = rbind(
	read.csv(file = datafile1),
	read.csv(file = datafile2)
)

sofia_geohash = rbind(
	read.csv(file = geohash_1),
	read.csv(file = geohash_2)
)
sofia_geohash = unique(sofia_geohash)
eea = read.csv(file = eea_file, stringsAsFactors = FALSE)
meteo = read.csv(file = meteo_file)

#	Clean CSV-s
#	Clean date dimension
date_dimension = date_dimension[, -1]

#	Fix EEA colnames
eea_real_colnames = as.character(eea[1, ])
eea_real_colnames[eea_real_colnames == "NA"] = colnames(eea)[eea_real_colnames == "NA"]
colnames(eea) = eea_real_colnames
eea = eea[-1, ]
colnames(eea)[colnames(eea) == "X"] = "year_day"

eea = data.frame(lapply(
	eea,
	as.numeric
))

#	Enhance eea
colnames(eea) = tolower(colnames(eea))
eea$var <- as.numeric(eea$var)
eea$station <- as.factor(eea$station)

eea$SamplingProcess <- ifelse((eea$station == "9421") | (eea$station == "9642"), "andersen", "thermo")

eea$building_distance <- ifelse(eea$station == "9642", 17,
							   ifelse(eea$station == "9572", 31,
							   	   ifelse(eea$station == "9421", 16,
							   	   	   ifelse(eea$station == "9484", 100,
							   	   	   	   ifelse(eea$station == "9616", 17,NA)))))

eea$kerp_distance <- ifelse(eea$station == "9642", 46,
						   ifelse(eea$station == "9572", 20,
						   	   ifelse(eea$station == "9421", 27,
						   	   	   ifelse(eea$station == "9484", 12,
						   	   	   	   ifelse(eea$station == "9616", 12,NA)))))

eea$station_type <- ifelse(eea$station == "9642", "background",
						  ifelse(eea$station == "9572", "background",
						  	   ifelse(eea$station == "9421", "background",
						  	   	   ifelse(eea$station == "9484", "traffic",
						  	   	   	   ifelse(eea$station == "9616", "traffic",NA)))))

eea$longitude <- ifelse(eea$station == "9642", 23.310972,
					   ifelse(eea$station == "9572", 23.296786,
					   	   ifelse(eea$station == "9421", 23.400164,
					   	   	   ifelse(eea$station == "9484", 23.33605,
					   	   	   	   ifelse(eea$station == "9616", 23.268403,NA)))))

eea$latitude <- ifelse(eea$station == "9642", 42.7322919999999,
					  ifelse(eea$station == "9572", 42.6805579999999,
					  	   ifelse(eea$station == "9421", 42.6665079999999,
					  	   	   ifelse(eea$station == "9484", 42.690353,
					  	   	   	   ifelse(eea$station == "9616", 42.6697969999999,NA)))))

eea$altitude <- ifelse(eea$station == "9642", 534,
					  ifelse(eea$station == "9572", 581,
					  	   ifelse(eea$station == "9421", 548,
					  	   	   ifelse(eea$station == "9484", 524,
					  	   	   	   ifelse(eea$station == "9616", 615,NA)))))

#	Prepare AirTube - limit to Sofia, convert time data to POSIXct, aggregate by day
air_tube = merge(
	air_tube,
	sofia_geohash[, "geohash"],
	by = "geohash"
)
nrow(air_tube)
length(unique(air_tube[, "geohash"]))

skip_cols = colnames(air_tube) %in% c("geohash", "time", "longitude", "latitude")
funs_to_do = c(
	length = length,
	mean = mean,
	min = min,
	max = max,
	var = var
)

air_tube_aggregated_list = lapply(
	seq(funs_to_do),
	function(fun_nr)
	{
		cur_fun = funs_to_do[[fun_nr]]
		cur_fun_name = names(funs_to_do)[fun_nr]
		
		result = aggregate.data.frame(
			x = air_tube[, !skip_cols],
			by = list(
				geohash = air_tube[, c("geohash")],
				time = as.Date(air_tube[, "time"])
			),
			FUN = function(x)
			{
				if (cur_fun_name == "length") {
					cur_fun(x)
				} else {
					cur_fun(x, na.rm = TRUE)
				}
			},
			drop = TRUE
		)
		colnames(result)[-c(1, 2)] = paste(
			colnames(result)[-c(1, 2)],
			cur_fun_name,
			sep = "_"
		)
		return(result)
	}
)
air_tube_aggregated = air_tube_aggregated_list[[1]]
for (item in air_tube_aggregated_list[-1]) {
	air_tube_aggregated = merge(
		air_tube_aggregated,
		item,
		all.x = TRUE,
		all.y = TRUE
	)
}

#	Give air_tube_aggregated its lon and lat BACK
air_tube_aggregated = merge(
	air_tube_aggregated,
	sofia_geohash,
	by = "geohash"
)

#	Clean meteo
bad_meteo_cols = which(colnames(meteo) %in% c("PRCPMAX", "PRCPMIN", "PRCPMAX"))
meteo = meteo[, -bad_meteo_cols]

# meteo$latitude <- 42.6537
# meteo$longitude <- 23.3829
# meteo$altitude <- 595
# meteo$day_of_year <- yday(as.Date(with(meteo, paste(year, Month, day,sep="-")), "%Y-%m-%d"))
meteo[, "time"] = as.Date(
	paste(
		meteo[, "year"],
		meteo[, "Month"],
		meteo[, "day"],
		sep = "-"
	)
)
meteo = meteo[!is.na(meteo[, "time"]), ]
meteo = meteo[, -which(colnames(meteo) %in% c("year", "Month", "day"))]

#	Rename meto cols to tell it apart from air_tube
colnames(meteo)[colnames(meteo) != "time"] = paste(
	"meteo",
	colnames(meteo)[colnames(meteo) != "time"],
	sep = "_"
)

#	Give air_tube stations unique ID-s
unique_air_tube_stations = data.frame(
	geohash = unique(air_tube_aggregated[, "geohash"]),
	station = NA
)
unique_air_tube_stations[, "station"] = seq(nrow(unique_air_tube_stations))
air_tube_aggregated = merge(
	air_tube_aggregated,
	unique_air_tube_stations,
	by = "geohash"
)

#	Rename eea columns to match air_tube_aggregated
colnames(eea) = c(
	"year_day",
	"P1_max",
	"P1_mean",
	"P1_min",
	"P1_length",
	"P1_sum",
	"P1_var",
	"station",
	"year",
	"SamplingProcess",
	"building_distance",
	"kerp_distance",
	"station_type",
	"longitude",
	"latitude",
	"altitude"
)
air_tube_only_cols = colnames(air_tube_aggregated)[!colnames(air_tube_aggregated) %in% colnames(eea)]
for (col in air_tube_only_cols) {
	eea[, col] = NA
}
eea_only_cols = colnames(eea)[!colnames(eea) %in% colnames(air_tube_aggregated)]
for (col in eea_only_cols) {
	air_tube_aggregated[, col] = NA
}

#	
#	Merge operations
#	

#	rbind eea and air_tube
eea_factor_cols = sapply(eea, class) == "factor"
air_tube_aggregated_factor_cols = sapply(air_tube_aggregated, class) == "factor"

eea[, eea_factor_cols] = sapply(eea[, eea_factor_cols], as.character)
air_tube_aggregated[, air_tube_aggregated_factor_cols] = sapply(
	air_tube_aggregated[, air_tube_aggregated_factor_cols], 
	as.character
)

data_analysis = rbind(
	eea,
	air_tube_aggregated,
	stringsAsFactors = FALSE
)

#	Join with date dimension
data_analysis = merge(
	data_analysis,
	date_dimension,
	by.x = "time",
	by.y = "date",
	all.x = TRUE
)

#	Join with meteo
data_analysis = merge(
	data_analysis,
	meteo,
	by = "time",
	all.x = TRUE
)

out_file = "0. Data/all_data_dirty.csv"
# out_file_summary = "3. Data Preparation/DP_021 Data Merge Summary.txt"

write.csv(file = out_file, x = data_analysis, row.names = FALSE)
