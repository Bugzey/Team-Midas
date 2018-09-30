library(tidyverse)

colnames(dirty) <- tolower(colnames(dirty))

cutoff_dist_9642 = as.numeric(summary(dirty$dist_9642)[2])
cutoff_dist_9572 = as.numeric(summary(dirty$dist_9572)[2])
cutoff_dist_9421 = as.numeric(summary(dirty$dist_9421)[2])
cutoff_dist_9616 = as.numeric(summary(dirty$dist_9616)[2])

p1_mean_9642 = dirty %>% select(time, station, mean) %>% filter(station == 9642) %>% select(-station)
p1_mean_9572 = dirty %>% select(time, station, mean) %>% filter(station == 9572) %>% select(-station)
p1_mean_9421 = dirty %>% select(time, station, mean) %>% filter(station == 9421) %>% select(-station)
p1_mean_9616 = dirty %>% select(time, station, mean) %>% filter(station == 9616) %>% select(-station)




filter_9421 = dirty %>% select(time, station, p1_mean, dist_9421) %>% 
  filter(!(station %in% c(9642,9572,9421,9616))) %>% 
  filter(dist_9421 < cutoff_dist_9421) %>% 
  left_join(p1_mean_9421, by = "time") %>% 
  mutate(p1_mean_new = ifelse(is.na(mean) == TRUE, p1_mean,
                              ifelse(is.na(p1_mean) == TRUE, mean,
                                     ifelse(p1_mean == 0, mean,
                                        ifelse(p1_mean > 3 * mean, mean,p1_mean))))) %>% 
  select(time, station, p1_mean_new)

filter_9642 = dirty %>% select(time, station, p1_mean, dist_9642) %>% 
  filter(!(station %in% c(9421,9572,9421,9616))) %>% 
  filter(dist_9642 < cutoff_dist_9642) %>% 
  left_join(p1_mean_9642, by = "time") %>% 
  mutate(p1_mean_new = ifelse(is.na(mean) == TRUE, p1_mean,
                              ifelse(is.na(p1_mean) == TRUE, mean,
                                     ifelse(p1_mean == 0, mean,
                                            ifelse(p1_mean > 3 * mean, mean,p1_mean)))))%>% 
  select(time, station, p1_mean_new)

filter_9616 = dirty %>% select(time, station, p1_mean, dist_9616) %>% 
  filter(!(station %in% c(9421,9572,9421,9642))) %>% 
  filter(dist_9616 < cutoff_dist_9616) %>% 
  left_join(p1_mean_9616, by = "time") %>% 
  mutate(p1_mean_new = ifelse(is.na(mean) == TRUE, p1_mean,
                              ifelse(is.na(p1_mean) == TRUE, mean,
                                     ifelse(p1_mean == 0, mean,
                                            ifelse(p1_mean > 3 * mean, mean,p1_mean)))))%>% 
  select(time, station, p1_mean_new)

filter_9572 = dirty %>% select(time, station, p1_mean, dist_9572) %>% 
  filter(!(station %in% c(9421,9616,9421,9642))) %>% 
  filter(dist_9572 < cutoff_dist_9572) %>% 
  left_join(p1_mean_9572, by = "time") %>% 
  mutate(p1_mean_new = ifelse(is.na(mean) == TRUE, p1_mean,
                              ifelse(is.na(p1_mean) == TRUE, mean,
                                     ifelse(p1_mean == 0, mean,
                                            ifelse(p1_mean > 3 * mean, mean,p1_mean)))))%>% 
  select(time, station, p1_mean_new)


jn <- full_join(filter_9572, filter_9616, by = c("time" = "time", "station" = "station")) %>% 
                          mutate(p1_mean = ifelse(is.na(p1_mean_new.x) == TRUE, p1_mean_new.y,
                          ifelse(is.na(p1_mean_new.y) == TRUE, p1_mean_new.x, p1_mean_new.x))) %>% 
      select(time, station, p1_mean)
                                
jn2 <-  full_join(jn, filter_9642, by = c("time" = "time", "station" = "station")) %>% 
  mutate(p1_mean = ifelse(is.na(p1_mean) == TRUE, p1_mean_new,
                          ifelse(is.na(p1_mean_new) == TRUE, p1_mean, p1_mean_new))) %>% 
  select(time, station, p1_mean)

jn3 <- full_join(jn, filter_9421, by = c("time" = "time", "station" = "station")) %>% 
  mutate(p1_mean = ifelse(is.na(p1_mean) == TRUE, p1_mean_new,
                          ifelse(is.na(p1_mean_new) == TRUE, p1_mean, p1_mean_new))) %>% 
  select(time, station, p1_mean)


clean <- left_join(dirty, jn3, by = c("time" = "time", "station" = "station"))

clean$p1_mean <- clean %>% select(mean, p1_mean.x, p1_mean.y) %>% 
  mutate(p1_mean_clean = ifelse(is.na(mean) == TRUE, p1_mean.x,
                        ifelse(is.na(p1_mean.x) == TRUE, mean, p1_mean.x))) %>% 
  select(p1_mean_clean) %>% 
  mutate(p1_mean = ifelse(p1_mean_clean > as.numeric(quantile(clean$p1_mean,0.9975, na.rm = T)), NA,p1_mean_clean) )
         