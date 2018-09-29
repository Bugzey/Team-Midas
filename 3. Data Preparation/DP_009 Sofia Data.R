
df <- read_csv("E:/Datathon Sept/Air Tube/data_bg_2017_2018.csv")
gh17 <- read_csv(file.choose())  
gh18 <- read_csv(file.choose())  
gh <- bind_rows(gh17,gh18)
gh <- gh %>% distinct()

sf <- inner_join(df,gh, by = "geohash")
write_csv(sf, "E:/Datathon Sept/Team-Midas/0. Data/sofia_people.csv")
