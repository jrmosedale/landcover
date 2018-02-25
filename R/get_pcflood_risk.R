library(flexdashboard)
library(shiny)
library(raster)
library(leaflet)
#library(DT)
library(magrittr)
library(colorspace)
library(rgeos)
library(ggplot2)
#library(shinyjs)
#library(plotly)
library(DiagrammeR)
library(rgdal)
library(sf)
#library(tidyverse)
library(leaflet.extras)

dir_ea<-"/Users/jm622/Data/EnvAgency/"
aoi_filename<-"/Users/jm622/Rprojects/landcover/masks/Cornwall.shp"

fzone2.uk<-st_read(paste0(dir_ea,"Flood_zone_2/nat_floodzone2_v201711.shp"))
fzone3.uk<-st_read(paste0(dir_ea,"Flood_zone_3/nat_floodzone3_v201711.shp"))
fwa.uk<-st_read(paste0(dir_ea,"Flood_Warning_Areas/Flood_Warning_PSF_ENG_20170711.shp"))

aoi<-st_read(aoi_filename)

fzone2.uk<-st_intersection(fzone2.uk,aoi)
