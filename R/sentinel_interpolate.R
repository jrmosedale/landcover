####################################################################################
# Interpolate across timeseries of Sentinel 2 images
# Load as tif files at native band resolution
# Uses cloud and scene masks at resolution of bands 
# Overlay on master raster at 10 and 20m resolutions
# -ve buffer to remove edge pixels
# Assign polygons as training or validation
####################################################################################

# Libraries
library(rgdal)
library(rgeos)
library(raster)
library(ggplot2)
library(sf)
library(lwgeom)

# Get parameters - SOURCE dir, TARGET dir, TILE, RESolution
param.res<-c(10,20,60)
param.source<-"/home/ISAD/jm622/sentinel/S2_2A_Products/UUA"
param.target<-"/home/ISAD/jm622/sentinel/S2_timeseries_2017/UUA"
#param.tile<-c("UUA","UUB","UVA","UVB") # and scilly isles tiles

# Define sample days of year for output
# divisers of 366: 1 2 3 6 61 122 183 366
param.sample.doys<-(seq(1,61,122,183)
seq(1,366,16)


# Interpolation methods
#raster::approxNA  (check predit)
r.stack<-approxNA(r.stack, filename="", method="linear", yleft, yright,
         rule=1, f=0, ties=mean, z=NULL, NArule=1, ...)
# z = time variable (DOY) for weighted interpolation
# Problem of when no valid pixel at start or end - rule 1=NA 2= closest valid data pt. Also NA rule - when only 1 valid value
# ref https://gist.github.com/johnbaums/10465462 - very similar Temporal interpolation

# QUestion - get from neighbouring pixels when no timeseries neighbour? ie calculate interpolation from mean of neighbours (or neighbour with closest value for same time)
# ie use spatial interpolation as well as linear (time) interpolation
# Spatial interpolation ref: http://rspatial.org/analysis/rst/4-interpolation.html
# Treat time as just another dimension to spatial x,y - 3D interpolation??? eg TPS??
# Or model on similar value cells at a valid time?




# Increasing speed of raster processing http://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/