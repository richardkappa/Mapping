#Get all of my shapefiles and ONS lookups
library(raster)
library(reshape2)
library(spatstat)
library(rgdal)
library(maptools)
library(dplyr)
library(rgeos)
library(plotGoogleMaps)


# Coordinate systems, looked up from epsg.org
latlong = "+init=epsg:4326"
OSGB = "+init=epsg:27700"

# Start with the Shapefiles

# Postcode related files
# From https://www.sharegeo.ac.uk/handle/10672/553
Post.Area.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/UK Postcodes","Areas")
Post.Dist.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/UK Postcodes","Districts")
Post.Sect.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/UK Postcodes","Sectors")

Post.Area.SP <- spTransform(Post.Area.SP,CRS(OSGB))
Post.Dist.SP <- spTransform(Post.Dist.SP,CRS(OSGB))
Post.Sect.SP <- spTransform(Post.Sect.SP,CRS(OSGB))

save(Post.Area.SP,Post.Dist.SP,Post.Sect.SP, file = "C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/PostShapes.RData")

# ONS shapefiles, from data.gov and geoportal.statistics.gov.uk
LSOA.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/LSOA Boundaries","LSOA_2011_EW_BGC_V2")
GovtOff.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/Govt Office Regions","GOR_DEC_2010_EN_BFE")
Country.SP <- readOGR("C:/Users/Richardkappa/Documents/Shapefiles/UK Countries","CTRY_DEC_2011_GB_BGC")


LSOA.SP <- spTransform(LSOA.SP,CRS(OSGB))
GovtOff.SP <- spTransform(GovtOff.SP,CRS(OSGB))
Country.SP <- spTransform(Country.SP,CRS(OSGB))

# Disolve the Countries to get just the boundary of Great Britain
Country.SP@data$GB <- "GB"
row.names(Country.SP) <- row.names(Country.SP@data)
Country.SP <- spChFIDs(Country.SP,row.names(Country.SP))

GB.SP <- gUnaryUnion(Country.SP,id=Country.SP@data$GB)

# Now get the lookups by LSOA

#  1 LAD - Loacal Authority District
# Import and clean the lookup, align the names with the standard naming conventions of the ONS
LSOA.LAD <- read.csv("C:/Users/Richardkappa/Documents/ONSLookups/LSOA01_LSOA11_LAD11_EW_LU.csv")
keep <- c("LSOA11CD", "LAD11CD", "LAD11NM")
names <- c("LSOA11CD", "LAD11CD", "LAD11NM")
LSOA.LAD <- LSOA.LAD[keep]
names(LSOA.LAD) <- names
# Remove duplicates
LSOA.LAD <- LSOA.LAD[!duplicated(LSOA.LAD),]


# 2 LSOA to City
LSOA.City <- read.csv("C:/Users/Richardkappa/Documents/ONSLookups/LSOA11_TCITY15_EW_LU.csv")
keep <- c("LSOA11CD", "TCITY15CD", "TCITY15NM")
names <- c("LSOA11CD", "TCITY15CD", "TCITY15NM")
LSOA.City <- LSOA.City[keep]
names(LSOA.City) <- names
LSOA.City <- LSOA.City[!duplicated(LSOA.City),]

#3 Population by LSOA (as at 2014)
LSOA.Population <- read.csv("C:/Users/Richardkappa/Documents/ONSLookups/SAPE17DT11-mid-2014-lsoa-population-density.csv")
keep <- c("Code", "Mid.2014.population")
names <- c("LSOA11CD", "Population")
LSOA.Population <- LSOA.Population[keep]
names(LSOA.Population) <- names
LSOA.Population <- LSOA.Population[!duplicated(LSOA.Population),]

#Merge the LAD data onto the LSOA data and disolve the inner boundaries

LAD.SP <- merge(LSOA.SP,LSOA.LAD,by="LSOA11CD",all.x=TRUE)
row.names(LAD.SP) <- row.names(LAD.SP@data)
LAD.SP <- spChFIDs(LAD.SP,row.names(LAD.SP))
LAD.SP <- gUnaryUnion(LAD.SP,id=LAD.SP@data$LAD11CD)

save(LSOA.SP,GovtOff.SP,GB.SP,LAD.SP, file = "C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSShapes.RData")
save(LSOA.City,LSOA.LAD,LSOA.Population,LSOA.LAD,file="C:/Users/Richardkappa/Documents/Shapefiles/R Shapefiles/ONSLookups.RData")
