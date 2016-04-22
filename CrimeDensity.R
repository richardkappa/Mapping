library(raster)
library(reshape2)
library(spatstat)
library(rgdal)
library(maptools)
library(dplyr)
library(rgeos)
library(plotGoogleMaps)

load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSShapes.RData")
load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSLookups.RData")
load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/PostShapes.RData")

# Coordinate systems, looked up from epsg.org
latlong = "+init=epsg:4326"
OSGB = "+init=epsg:27700"


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
months <- c("2016-02")

dir <- "C:/Users/Richardkappa/Documents/PoliceData/"

for (j in 1:length(months)) {
  
  
  for (i in 1:length(force_list)){
    
    File <-  paste(dir,months[j],"/",months[j],"-",force_list[i],"-street.csv",sep="")
    print(File)
    ifelse(i<=1, Crime <- read.csv(File),Crime<-rbind(Crime,read.csv(File)))
    print(nrow(Crime))
  }
  # Change the month variable into a date format
  Crime$Date <- as.Date(ISOdate(as.numeric(substr(Crime$Month,1,4)),
                                as.numeric(substr(Crime$Month,6,7)),1))
  Crime$Year <- as.numeric(substr(Crime$Month,1,4))
}

# Drop any rows with missing longitudes or latitudes
Crime.Sub <- subset(Crime, Longitude!=""&Latitude!="")[c("Crime.type", "Longitude", "Latitude", "LSOA.code")]

# Create a unique id for each row (CrimeID is sometimes missing)
Crime.Sub$ID <- NA
Crime.Sub$ID <- 1:nrow(Crime.Sub)
keep <- c("ID","Crime.type", "Longitude", "Latitude", "LSOA.code")
names <-c("ID","Crime.type", "Longitude", "Latitude", "LSOA11CD")
Crime.Sub <- Crime.Sub[keep]
names(Crime.Sub)<-names

# Create the spatialpointsdataframe
coords <- cbind(Longitude=as.numeric(as.character(Crime.Sub$Longitude)), Latitude=as.numeric(as.character(Crime.Sub$Latitude)))
Crime.LongLat <- SpatialPointsDataFrame(coords, data = data.frame(Crime.Sub$ID, Crime.Sub$Crime.type), proj4string = CRS(latlong))

# Convert from WGS84 to OSGB36
Crime.OSGB <- spTransform(Crime.LongLat,CRS(OSGB))

# Remove working data
rm(coords, Crime.Sub, Crime.LongLat)

# Use Spatstat features to calculate plot the crime density in the UK
overlay <- over(Crime.OSGB,GB.SP)
Crime.OSGB$Over <- overlay$name 
Crime.GB <- Crime.OSGB[!is.na(Crime.OSGB$Over),]


window <- as.owin.SpatialPolygons(GB.SP)

Crime.Samp <- remove.duplicates(Crime.GB)

Crime.ppp <- ppp(x=Crime.GB@coords[,1],y=Crime.Samp@coords[,2],window=window)

Crime.Density <- density.ppp(Crime.ppp)

plot(Crime.Density)
