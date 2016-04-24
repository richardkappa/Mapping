library(raster)
library(reshape2)
library(spatstat)
library(rgdal)
library(maptools)
library(dplyr)
library(rgeos)
library(plotGoogleMaps)


# A list of all of the forces 
# Excluding british transport police because this made the code error out
force_list <- c(
  "avon-and-somerset", "bedfordshire", "cambridgeshire", "cheshire"
  , "city-of-london", "cleveland", "cumbria", "derbyshire", "devon-and-cornwall"
  , "dorset", "durham", "dyfed-powys", "essex", "gloucestershire", "greater-manchester", "gwent"
  , "hampshire", "hertfordshire", "humberside", "kent", "lancashire", "leicestershire"
  , "lincolnshire", "merseyside", "metropolitan", "norfolk", "north-wales", "north-yorkshire"
  , "northamptonshire", "northern-ireland", "northumbria", "nottinghamshire", "south-wales"
  , "south-yorkshire", "staffordshire", "suffolk", "surrey", "sussex", "thames-valley"
  , "warwickshire", "west-mercia", "west-midlands", "west-yorkshire", "wiltshire"
)

# The time period to run this over
# For testing use 1 month
months <- c("2015-01", "2015-02", "2015-03", "2015-04", "2015-05", "2015-06", 
            "2015-07", "2015-08", "2015-09", "2015-10", "2015-11", "2015-12")

dir <- "C:/Users/Richardkappa/Documents/PoliceData/"


for (j in 1:length(months)) {
  
  
  for (i in 1:length(force_list)){
    
    File <-  paste(dir,months[j],"/",months[j],"-",force_list[i],"-street.csv",sep="")
    print(File)
    ifelse(i<=1, Crime <- read.csv(File),Crime<-rbind(Crime,read.csv(File)))
    
  }
  # Change the month variable into a date format
  Crime$Date <- as.Date(ISOdate(as.numeric(substr(Crime$Month,1,4)),
                                as.numeric(substr(Crime$Month,6,7)),1))
  Crime$Year <- as.numeric(substr(Crime$Month,1,4))
  
  assign(paste0("Crime",months[j]),Crime)
}

save("Crime2015-01","Crime2015-02","Crime2015-03","Crime2015-04",
     "Crime2015-05","Crime2015-06","Crime2015-07","Crime2015-08",
     "Crime2015-09","Crime2015-10","Crime2015-11","Crime2015-12", 
     file="C:/Users/Richardkappa/Documents/Crime Data/Crime.OSGB.months.RData")
