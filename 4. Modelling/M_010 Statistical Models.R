#	
#	M_010 Statistical Models.R
#	
#	Attempts to model particulate matter concentrations via traditional statistical models
#	

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
