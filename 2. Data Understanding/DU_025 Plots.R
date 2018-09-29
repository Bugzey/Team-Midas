#########
#  EDA  #
#########

summary(df)

ggplot(df) + geom_line(aes(time,P1))

ggplot(df) + geom_line(aes(time,temperature))

ggplot(df) + geom_line(aes(time,humidity))

ggplot(df) + geom_line(aes(time,pressure))
