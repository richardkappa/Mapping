# Calculate the density

library(raster)
library(reshape2)
library(spatstat)
library(rgdal)
library(maptools)
library(dplyr)
library(rgeos)
library(plotGoogleMaps)

# load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSShapes.RData")
# load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSLookups.RData")
load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/PostShapes.RData")
load(file="C:/Users/Richardkappa/Documents/Crime Data/Crime.OSGB.2015.RData")
load(file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/UKCounty Shapefiles.RData")

#Remove not needed files
rm(Post.Dist.SP,Post.Area.SP2,Post.Sect.SP, UK.Country.SP,UK.County.SP)

# Coordinate systems, looked up from epsg.org
latlong = "+init=epsg:4326"
OSGB = "+init=epsg:27700"

# All of the crime types
names <- c("Anti-Social Behaviour", "Bicycle Theft", 
           "Burglary", "Criminal Damage and Arson", "Drugs", "Other Crime", "Other Theft",
           "Possession of Weapons", "Public Order", "Robbery", "Shoplifting", 
           "Theft from the Person", "Vehicle Crime", "Violence and Sexual Offences", 
           "Total Crimes")

# Use Spatstat features to calculate plot the crime density in the UK

# First work with just a sample window
map.shape <- UK.SP
  #UK.SP
  #Post.Area.SP[Post.Area.SP$name=="LA",]

# Get the crimes from within the polygons
overlay <- over(Crime.OSGB,map.shape)
Crime.OSGB$Over <- overlay$name 
Crime.GB <- Crime.OSGB[!is.na(Crime.OSGB$Over),]

# Convert the map polygon to the owin format
window <- as.owin.SpatialPolygons(map.shape)

# Remove duplicate points
Crime.Samp <- remove.duplicates(Crime.GB)

# Get the crime points from within the window
Crime.ppp <- ppp(x=Crime.GB@coords[,1],
                 y=Crime.Samp@coords[,2],
                 window=window)

#Get the indivudual crime data
marks<-data.frame(Crime.GB@data[,c(1:15)])

#Convert NAs to 0
marks[is.na(marks)] <- 0

#Add marks to ppp
marks(Crime.ppp)<- marks

# Calcuate the crime density
Crime.Density <- density.ppp(Crime.ppp,
                             diggle = TRUE,
                             sigma=250, 
                             edge=T,
                             W=as.mask(window,eps=c(1000,1000)),
                             weights=Crime.ppp$marks[,c(2,3,7,10,11,12,15)])

jpeg("MapCrimeDensity.jpeg",5000,3500,res=10)
plot(Crime.Density)
dev.off()

# Plot on a google map
# Convert the density ppp to raster format
Raster.Bicycle.Theft <- raster(Crime.Density$Bicycle.Theft)
Raster.Burglary <- raster(Crime.Density$Burglary)
Raster.Other.Theft <- raster(Crime.Density$Other.Theft)
Raster.Robbery <- raster(Crime.Density$Robbery)
Raster.Shoplifting <- raster(Crime.Density$Shoplifting)
Raster.Theft.from.the.Person <- raster(Crime.Density$Theft.from.the.Person)
Raster.Total.Crimes <- raster(Crime.Density$Total.Crimes)


projection(Raster.Bicycle.Theft) <- projection(map.shape)
projection(Raster.Burglary) <- projection(map.shape)
projection(Raster.Other.Theft) <- projection(map.shape)
projection(Raster.Robbery) <- projection(map.shape)
projection(Raster.Shoplifting) <- projection(map.shape)
projection(Raster.Theft.from.the.Person) <- projection(map.shape)
projection(Raster.Total.Crimes) <- projection(map.shape)

# Plot on a map
m <- plotGoogleMaps(Raster.Burglary,
                    filename="CrimeDensity.html", 
                    layerName = "Burglary", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0,
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE)

m <- plotGoogleMaps(Raster.Theft.from.the.Person, 
                    filename="CrimeDensity.html", 
                    layerName = "Theft from a person", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE,
                    previousMap = m)

m <- plotGoogleMaps(Raster.Shoplifting, 
                    filename="CrimeDensity.html", 
                    layerName = "Shoplifting", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE,
                    previousMap = m)

m <- plotGoogleMaps(Raster.Robbery, 
                    filename="CrimeDensity.html", 
                    layerName = "Robbery", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE,
                    previousMap = m)

m <- plotGoogleMaps(Raster.Other.Theft, 
                    filename="CrimeDensity.html", 
                    layerName = "Other Theft", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE,
                    previousMap = m)

m <- plotGoogleMaps(Raster.Bicycle.Theft, 
                    filename="CrimeDensity.html", 
                    layerName = "Bicycle Theft", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    add=TRUE,
                    previousMap = m)

m <- plotGoogleMaps(Raster.Total.Crimes, 
                    filename="CrimeDensity.html", 
                    layerName = "Total Crimes", 
                    fillOpacity = 0.4, 
                    strokeWeight = 0, 
                    mapTypeId="ROADMAP",
                    colPalette = rev(heat.colors(20)),
                    legend=FALSE,
                    previousMap = m)
