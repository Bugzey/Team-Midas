#   DU_010 Dates and times.py

#   Purpose: Analyse what dates are available in the dataset - to get a common
#   timeframe of our date
#   Working directory: ~/2. Data Understanding/

rm(list = ls())
project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

data_dir = "0. Data"
data_understanding_dir = "2. Data Understanding"

all_files = dir(path = data_dir, pattern = "csv$", recursive = TRUE)
all_files = all_files[!grepl(all_files, pattern = "sample")]

encodings = rep("UTF-8", length(all_files))
encodings[grep(all_files, pattern = "EEA Data")] = "UTF-16"

data_headers = mapply(
	file = all_files,
	encoding = encodings,
	function(file, encoding)
	{
		readLines(
			con = file(
				paste(data_dir, file, sep = "/"),
				encoding = encoding
			),
			n = 1,
			encoding = encoding
		)
	}
)

col_names = strsplit(data_headers, split = ",")
col_names

#	Get all time cols
time_pattern = ".*(date)|(time)|(day)|(month)|(year).*"
time_cols =  sapply(
	col_names,
	function(col)
		grep(col, pattern = time_pattern, value = TRUE, ignore.case = TRUE)
)
time_cols

#	Load just the time cols from each csv
read_col_classes = lapply(
	seq(col_names),
	function(cur_file)
	{
		all_names = col_names[[cur_file]]
		cur_time_cols = time_cols[[cur_file]]
		result = ifelse(all_names %in% cur_time_cols, "character", "NULL")
		return(result)
	}
)
input_data = mapply(
	csv = all_files,
	cols = read_col_classes,
	encoding = encodings,
	function(csv, cols, encoding)
	{
		cur_con = file(description = paste(data_dir, csv, sep = "/"), encoding = encoding)
		read.csv(
			file = cur_con,
			header = TRUE,
			colClasses = cols,
			encoding = encoding
		)
	}
)

#	Convert the time cols to a useable datetime format -- e.g. POSIXct / POSIXlt
#	Half manual, since i can't be bothered
conv_posix = function(df)
{
	sapply(
		df,
		function(col)
			tryCatch(
				expr = {as.POSIXct(col)},
				error = as.character(col)
			)
	)
}
conv_parts = function(df, year = "year", month = "month", day = "day")
{
	year_col = df[, grep(colnames(df), pattern = year, ignore.case = TRUE)]
	month_col = df[, grep(colnames(df), pattern = month, ignore.case = TRUE)]
	day_col = df[, grep(colnames(df), pattern = day, ignore.case = TRUE)]
	
	new_value = as.POSIXct(paste(year_col, month_col, day_col, sep = "-"))
	df[, "posix_date"] = new_value
	return(df)
}

end_data = list(
	lapply(
		seq(30),
		function(item)
			conv_posix(input_data[[item]])
	),
	conv_parts(input_data[[31]]),
	input_data[[32]]
)

#	Make a summary of the data

#	Get missing or odd dates