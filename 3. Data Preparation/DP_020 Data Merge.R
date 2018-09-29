#	
#	DP_020 Data Merge.R
#	
#	Merge all processed datasets into one analysis dataset


rm(list = ls())
project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

data_dir = "0. Data"
data_understanding_dir = "2. Data Understanding"

datafile1 <- "0. Data/Air Tube/data_bg_2017.csv"
datafile2 <- "0. Data/Air Tube/data_bg_2018.csv"

geohash_1 = "0. Data/geohash_mapping_sofia_2017_unique.csv"
geohash_2 = "0. Data/geohash_mapping_sofia_2018_unique.csv"

eea_file = "0. Data/EEA Data-20180928T184849Z-001/EEA Data/eea_final.csv"

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

#	Inner join air_tube to sofia geohash data
data_analysis = merge(
	air_tube,
	sofia_geohash,
	by = "geohash"
)

#	Fix EEA colnames
eea_colnames = as.character(eea[1, ])
colnames(eea)[-c(1:4)] = eea_colnames[-c(1:4)]
eea = eea[-1, ]

eea[, -c(1:4)] = sapply(
	eea[, -c(1:4)],
	as.numeric
)

eea = eea[, -1]

