setwd("Z:/Joanna/Biosurvey/Biosurvey")
if(!require(remotes)){
  install.packages("remotes")
}

# To install the package use
remotes::install_github("claununez/biosurvey")

# Installing and loading packages
if(!require(devtools)){
  install.packages("devtools")
}

if(!require(kuenm)){
  devtools::install_github("marlonecobos/kuenm")
}

library(kuenm)
install.packages("raster")
library(biosurvey)
library(raster)
#install.packages("terra")
library(terra)
## reading data
#environmental data
varaibles_list <- list.files(path = "data/2_5m_mean_00s", pattern = ".tif", # vector of variables
                             full.names = TRUE)

#variables <- stack(varaibles_list) # stack of variables
variables<-rast(varaibles_list)
f <- "Z:/Joanna/Biosurvey/Biosurvey/data/northamericashapefile/boundaries_p_2021_v3.shp"
f
shapefile<-vect(f) #shapefile of north america for region of interest data
plot(shapefile)
# Sites selected a priori
# Create a data frame of pre-selected sites with coordinates for Atlanta and Kansas City
pre_selected_sites <- data.frame(
  city = c("Atlanta", "Kansas City", "New York City"),
  longitude = c(-84.3885, -94.578567, -74.0060),  # Longitude for Atlanta, Kansas City and NYC
  latitude = c(33.7501, 39.099727, 40.7128)      # Latitude for Atlanta, Kansas City and NYC
)

# You can convert this data frame into a spatial object
pre_selected_sites_sp <- vect(pre_selected_sites, geom = c("longitude", "latitude"), crs = "EPSG:4326")

# Check the pre-selected sites
pre_selected_sites_sp

# impervious surface area data
g<- "Z:/Joanna/Biosurvey/Biosurvey/data/EstISA_final.tif/EstISA_final.tif"
isa<-rast(g)
plot(isa)

#I want to crop isa by shapefile to restrict isa to north american cities

# need to reproject so shapefile and isa are in same crs
shapefile<-project(shapefile, crs(isa))
plot(crop(isa, shapefile))
plot(shapefile) #shapefile goes too far in longitude
ext(shapefile)
#define new extent
new_extent <- ext(-179.148909,-40,14.5350742414382, 83.137086408232)
shapefile<-crop(shapefile,new_extent)
plot(shapefile)

#now crop isa by shapefile and the result is impervious surface area of only north america
isa<-crop(isa, shapefile)

# ok now I need population density data
mexico<-"Z:/Joanna/Biosurvey/Biosurvey/data/mex_pd_2020_1km.tif"
mexico<-rast(mexico)
usa<-"Z:/Joanna/Biosurvey/Biosurvey/data/usa_pd_2020_1km.tif"
usa<-rast(usa)
can<-"Z:/Joanna/Biosurvey/Biosurvey/data/can_pd_2020_1km.tif"
can<-rast(can)
pd<-mosaic(mexico,usa,can)#combine all rasters into 1 population density layer
plot(pd) #check that I don't need to fix the extent or anything
pd<-crop(pd,new_extent) #now pd will match extent of everything else

# Now I have all my data, I need to set thresholds for masks and build masks
# also pretty sure everything should be same resolution...read about that and see about conveerting eerything to 2.5 arcminutes

