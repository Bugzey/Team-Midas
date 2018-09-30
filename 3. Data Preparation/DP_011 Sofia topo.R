#	
#	DP_011 Sofia topo.R
#	
#	Merges topological data with existing geohashes by grabbing the nearest topo point

rm(list = ls())
dependencies = list("geosphere")
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

topo_data <- "0. Data/TOPO-DATA/sofia_topo.csv"
sofia_topo <- read.csv(file = topo_data)

geohash_1 = "0. Data/geohash_mapping_sofia_2017_unique.csv"
geohash_2 = "0. Data/geohash_mapping_sofia_2018_unique.csv"

out_file = "0. Data/geohash_mapping_sofia.csv"

sofia_geohash = rbind(
  read.csv(file = geohash_1),
  read.csv(file = geohash_2)
)

sofia_geohash = unique(sofia_geohash)

sofia_geohash$altitude <- rep(0,nrow(sofia_geohash))
for (i in 1:nrow(sofia_geohash)) {
  sofia_geohash$altitude[i] <- as.numeric(sofia_topo[which.min(distVincentyEllipsoid(sofia_geohash[i,2:3], sofia_topo[,1:2])),3])  
}

write.csv(x = sofia_geohash, file = out_file, row.names = FALSE)
