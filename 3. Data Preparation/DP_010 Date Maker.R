#	
#	DP_010 Date Maker
#
#	Makes a data frame (csv) of dates, date parts and inputs holidays

#	Workspace
rm(list = ls())
project_dir = "~/Desktop/Team Midas/"
setwd(project_dir)

data_dir = "0. Data"
data_understanding_dir = "2. Data Understanding"
data_prep_dir = "3. Data Preparation"

out_file = paste(data_dir, "date_dimension.csv", sep = "/")

start_date = "2013-01-01"
end_date = "2018-09-17"

make_date_sequence = function(start, end)
{
	start_date = as.Date(start)
	end_date = as.Date(end)
	date_seq = seq.Date(from = start_date, to = end_date, by = "day")
	return(date_seq)
}

decompose_to_parts = function(date_seq)
{
	date = date_seq
	month_day = strftime(date, "%d")
	month = strftime(date, "%m")
	year = strftime(date, "%Y")
	week = strftime(date, "%V")
	week_day = strftime(date, "%u")
	year_day = strftime(date, "%j")
	
	result = data.frame(
		date = date,
		month_day = month_day,
		month = month,
		year = year,
		week = week,
		week_day = week_day,
		year_day = year_day,
		stringsAsFactors = FALSE
	)
	result[, -1] = sapply(
		result[, -1],
		as.integer
	)
	return(result)
}

make_holidays = function(start, end)
{
	holidays_easter = "2000 30 04
	2001 15 04
	2002 5 05
	2003 27 04
	2004 11 04
	2005 1 05
	2006 23 04
	2007 8 04
	2008 27 04
	2009 19 04
	2010 4 04
	2011 24 04
	2012 15 04
	2013 5 05
	2014 20 04
	2015 12 04
	2016 1 05
	2017 16 04
	2018 8 04
	2019 28 04
	2020 19 04
	2021 2 05
	2022 24 04"
	holidays_easter = strsplit(holidays_easter, split = "\\n")[[1]]
	holidays_easter = sapply(holidays_easter, gsub, pattern = "^\\s+|\\s+$", replacement = "", USE.NAMES = FALSE)
	holidays_easter = as.Date(holidays_easter, format = "%Y %d %m")
	holidays_easter = c(
		holidays_easter,
		holidays_easter - 1,
		holidays_easter - 2
	)
	holidays_easter = holidays_easter[order(holidays_easter)]
	
	holidays_fixed = "1 01
3 03 
1 05 
6 05 
24 05 
6 09 
22 09 
1 11 
24 12 
25 12 
26 12"
	holidays_fixed = strsplit(holidays_fixed, split = "\n")[[1]]
	holidays_fixed = gsub(holidays_fixed, pattern = "^\\s+|\\s+$", replacement = "")
	holidays_fixed = strsplit(holidays_fixed, split = " ")
	holidays_fixed = t(sapply(
		holidays_fixed,
		function(row) 
			c(day = as.integer(row[1]), month = as.integer(row[2]))
		)
	)
	
	date_seq = seq.Date(as.Date(start), as.Date(end), by = "day")
	df = data.frame(
		date = date_seq,
		day = as.integer(strftime(date_seq, format = "%d")),
		month = as.integer(strftime(date_seq, format = "%m"))
	)
	
	df = merge(
		df,
		data.frame(date = holidays_easter, holiday = 1),
		by = "date",
		all.x = TRUE
	)
	df = merge(
		df,
		data.frame(holidays_fixed, holiday = 1),
		by = c("day", "month"),
		all.x = TRUE
	)
	df[, "holiday"] = as.integer(!is.na(df[, "holiday.x"]) | !is.na(df[, "holiday.y"]))
	
	result = df[, c("date", "holiday")]
	return(result)
}

make_long_weekend = function(week_day, holiday)
{
	long_weekend_thu = which(week_day == 4 & holiday)
	long_weekend_fri = which(week_day == 5 & holiday)
	long_weekend_mon = which(week_day == 1 & holiday)
	long_weekend_tue = which(week_day == 2 & holiday)
	
	long_weekend_thu = sort(unlist(lapply(seq(0,3), function(x) long_weekend_thu + x)))
	long_weekend_fri = sort(unlist(lapply(seq(0,2), function(x) long_weekend_fri + x)))
	long_weekend_mon = sort(unlist(lapply(seq(0,2), function(x) long_weekend_mon - x)))
	long_weekend_tue = sort(unlist(lapply(seq(0,3), function(x) long_weekend_tue - x)))
	long_weekend = rep(0, length(week_day))
	long_weekend[long_weekend_thu[long_weekend_thu > 0]] = 1
	long_weekend[long_weekend_fri[long_weekend_fri > 0]] = 1
	long_weekend[long_weekend_mon[long_weekend_mon > 0]] = 1
	long_weekend[long_weekend_tue[long_weekend_tue > 0]] = 1
	
	return(long_weekend)
}

date_seq = make_date_sequence(start_date, end_date)
df = decompose_to_parts(date_seq)
holidays = make_holidays(start = start_date, end = end_date)

df = merge(df, holidays, by = "date", all.x = TRUE)

df[, "long_weekend"] = make_long_weekend(df[, "week_day"], df[, "holiday"])

#	Export
write.csv(x = df, file = out_file)
