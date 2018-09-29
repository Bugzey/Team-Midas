#######################
#   load the data     #
#######################
datafile <- "E:/Datathon Sept/Air Tube/data_bg_2017.csv"
df17 <- read_csv(datafile)

datafile <- "E:/Datathon Sept/Air Tube/data_bg_2018.csv"
df18 <- read_csv(datafile)

df <- bind_rows(df17, df18)

write_csv(df, "E:/Datathon Sept/Air Tube/data_bg_2017_2018.csv")







