#	Test out elevation data

rm(list = ls())
project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

data_dir = "0. Data"
data_understanding_dir = "2. Data Understanding"

elevation = read.csv(
	file = "0. Data/TOPO-DATA/sofia_topo.csv"
)

