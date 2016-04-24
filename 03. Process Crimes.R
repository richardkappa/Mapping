library(raster)
library(reshape2)
library(spatstat)
library(rgdal)
library(maptools)
library(dplyr)
library(rgeos)
library(plotGoogleMaps)

# Get the monthly data
load(file="C:/Users/Richardkappa/Documents/Crime Data/Crime.OSGB.months.RData")

# Combine the monthly data for a whole year

Crime <- rbind(`Crime2015-01`, `Crime2015-02`, `Crime2015-03`, `Crime2015-04`, 
               `Crime2015-05`, `Crime2015-06`, `Crime2015-07`, `Crime2015-08`,
               `Crime2015-09`, `Crime2015-10`, `Crime2015-11`, `Crime2015-12`)

rm(`Crime2015-01`, `Crime2015-02`, `Crime2015-03`, `Crime2015-04`, 
   `Crime2015-05`, `Crime2015-06`, `Crime2015-07`, `Crime2015-08`,
   `Crime2015-09`, `Crime2015-10`, `Crime2015-11`, `Crime2015-12`)

# Keep just the columns needed and rename with standardised names

Crime$Crimes <- 1
keep <- c("Date", "Year", "LSOA.code", "Crime.type", "Longitude", "Latitude", "Crimes")
names <- c("Date", "Year", "LSOA11CD", "Crime.Type", "Longitude", "Latitude", "Crimes")
Crime <- Crime[keep]
names(Crime)<- names

# Remove rows with missing coordinates or LSOA11CDs
Crime <- subset(Crime,Crime$LSOA11CD !=""|Crime$Longitude !=""|Crime$Latitude !="")

# Aggregate by point and crime type
Crime.BD <- aggregate(Crime$Crimes, by=list(Crime$Longitude, Crime$Latitude, Crime$Crime.Type), sum)
names <- c("Longitude", "Latitude", "Crime.Type", "Crimes")
names(Crime.BD) <- names

# Transpose the data
Crime.Trans <- dcast(Crime.BD, Crime.BD$Longitude+Crime.BD$Latitude~Crime.BD$Crime.Type)

# Calculate the total number of crimes at each point
Crime.Trans$TotalCrimes <- rowSums(Crime.Trans[,c(-1,-2)],na.rm = TRUE)

names <- c("Longitude", "Latitude","Anti-Social Behaviour", "Bicycle Theft", 
  "Burglary", "Criminal Damage and Arson", "Drugs", "Other Crime", "Other Theft",
  "Possession of Weapons", "Public Order", "Robbery", "Shoplifting", 
  "Theft from the Person", "Vehicle Crime", "Violence and Sexual Offences", 
  "Total Crimes")
names(Crime.Trans) <- names

rm(Crime, Crime.BD)

# Coordinate systems, looked up from epsg.org
latlong = "+init=epsg:4326"
OSGB = "+init=epsg:27700"

# Create the spatialpointsdataframe
coords <- cbind(Longitude=as.numeric(as.character(Crime.Trans$Longitude))
              , Latitude=as.numeric(as.character(Crime.Trans$Latitude)))

Crime.LongLat <- SpatialPointsDataFrame(coords, data = Crime.Trans[,c(-1,-2)], 
                                        proj4string = CRS(latlong))

# Convert from WGS84 to OSGB36
Crime.OSGB <- spTransform(Crime.LongLat,CRS(OSGB))

# Save the output
save(Crime.OSGB,
     file="C:/Users/Richardkappa/Documents/Crime Data/Crime.OSGB.2015.RData")


