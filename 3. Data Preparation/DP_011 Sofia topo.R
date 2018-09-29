library(geosphere)

topo_data <- "E:/Datathon Sept/TOPO-DATA/sofia_topo.csv"

sofia_topo <- read_csv(file = topo_data)

geohash_1 = "E:/Datathon Sept/Team-Midas/0. Data/geohash_mapping_sofia_2017_unique.csv"
geohash_2 = "E:/Datathon Sept/Team-Midas/0. Data/geohash_mapping_sofia_2018_unique.csv"


sofia_geohash = rbind(
  read.csv(file = geohash_1),
  read.csv(file = geohash_2)
)

sofia_geohash = unique(sofia_geohash)

sofia_geohash$altitude <- rep(0,nrow(sofia_geohash))
for (i in 1:nrow(sofia_geohash)) {
  sofia_geohash$altitude[i] <- as.numeric(sofia_topo[which.min(distVincentyEllipsoid(sofia_geohash[i,2:3], sofia_topo[,1:2])),3])  
}

write_csv(sofia_geohash, "E:/Datathon Sept/Team-Midas/0. Data/geohash_mapping_sofia.csv")
