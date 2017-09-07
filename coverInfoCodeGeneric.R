#code adapted from https://stackoverflow.com/questions/15824853/large-img-file-processing-in-r-gis & http://mbjoseph.github.io/2014/11/08/nlcd.html
#download the nlcd files from https://www.mrlc.gov/nlcd11_data.php (NLCD 2011 Land Cover or more recent)
#when using this code, make sure to check the all caps parts to replace with your own file details as needed


#load libraries
library(raster)
library(sp)
library(rgdal)
library(stringr)

#set working directory
setwd("PATH TO FOLDER WITH RASTER IMG FILE")

#load in map
NLCD <- raster ("NLCD RASTER .IMG FILE")
#load in loactions
sites <- read.csv("COORDS .CSV FILE", header=T)

#these next few are OPTIONAL, I occasionally had problems that this fixed
#check if sites has missing coords (and make sure no NA in any other columns)
#####apply(sites, 2, function(x) any(is.na(x)))
#remove rows with no coordinates
#####sitesN <- na.omit(sites)
#double check that sitesN doesn't have missing coords
#####apply(sitesN, 2, function(x) any(is.na(x)))
#if this is used, most times "sites" appears below it will need to be changed to sitesN for consistency

#if you do use the above three lines of code, make sure to change sites[,c("longitude", "latitude")] to sitesN[,c("longitude", "latitude")] below
#crop site data to just latitude and longitude in sitesL
#MAKE SURE TO USE THE ORIGNIAL COLUMN NAMES (not "longitude" and "latitude" if you have different names or capitalization)
sitesL <- sites[,c("longitude", "latitude")]

#rename to Longitude and Latitude (if your csv has slightly different names for longitude or latitude (here are a few))
names(sitesL)[names(sitesL) == "x"] <- "Longitude"
names(sitesL)[names(sitesL) == "y"] <- "Latitude"
names(sitesL)[names(sitesL) == "longitude"] <- "Longitude"
names(sitesL)[names(sitesL) == "latitude"] <- "Latitude"
#convert lat/lon to appropriate projection
str(sitesL)
coordinates(sitesL)  <-  c("Longitude",  "Latitude")
proj4string(sitesL)  <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
sites_transformed<-spTransform(sitesL, CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

#plot the map (don't need to do this to get the data in the excel file)
plot (NLCD)
#add the converted x y points
points (sites_transformed, pch=1, col="purple", cex=.75)
#extract values to points, buffer is in meters (MOST LIKELY, since the data is projected)  [If the data are not projected (latitude/longitude), the unit should be meters. Otherwise it should be in map-units (typically also meters).]
#can set the buffer to any distance you want the summary land cover of the area to include, however, if you go too low, it will only have one land cover type or will give you an error (the original data is only every so many meters in the first place)
Landcover <- extract (NLCD, sites_transformed, buffer=30)

# summarize each site's data by proportion of each cover type
summ <- lapply(Landcover, function(x) prop.table(table(x)))

#adds back in the original data (change all of the "sites" in this bit to "sitesN" if using the removing empty coordinates code)
mydf <- as.data.frame(data.frame(Name = rep(sites$name, lapply(summ, length)),  
                                 Longitude = rep(sites$longitude, lapply(summ, length)), Latitude = rep(sites$latitude, lapply(summ, length)),
                                 cover_number = names(unlist(summ)), percent = unlist(summ)))
mydf <- as.data.frame(mydf)
mydf$cover_names[mydf$cover_number==11] <- "Open Water" 
mydf$cover_names[mydf$cover_number==12] <- "Perennial Ice/Snow" 
mydf$cover_names[mydf$cover_number==21] <- "Developed, Open Space" 
mydf$cover_names[mydf$cover_number==22] <- "Developed, Low Intensity" 
mydf$cover_names[mydf$cover_number==23] <- "Developed, Medium Intensity" 
mydf$cover_names[mydf$cover_number==24] <- "Developed, High Intensity" 
mydf$cover_names[mydf$cover_number==31] <- "Barren Land (Rock/Sand/Clay)"
mydf$cover_names[mydf$cover_number==41] <- "Deciduous Forest" 
mydf$cover_names[mydf$cover_number==42] <- "Evergreen Forest" 
mydf$cover_names[mydf$cover_number==43] <- "Mixed Forest"
mydf$cover_names[mydf$cover_number==51] <- "Dwarf Scrub" 
mydf$cover_names[mydf$cover_number==52] <- "Shrub/Scrub" 
mydf$cover_names[mydf$cover_number==71] <- "Grassland/Herbaceous" 
mydf$cover_names[mydf$cover_number==72] <- "Sedge/Herbaceous" 
mydf$cover_names[mydf$cover_number==73] <- "Lichens" 
mydf$cover_names[mydf$cover_number==74] <- "Moss" 
mydf$cover_names[mydf$cover_number==81] <- "Pasture/Hay" 
mydf$cover_names[mydf$cover_number==82] <- "Cultivated Crops" 
mydf$cover_names[mydf$cover_number==90] <- "Woody Wetlands" 
mydf$cover_names[mydf$cover_number==95] <- "Emergent Herbaceous Wetlands" 


#output to excel
library(rJava)
library(xlsx)
write.xlsx(mydf, "FINAL FILE NAME .XLSX", row.names=FALSE)

