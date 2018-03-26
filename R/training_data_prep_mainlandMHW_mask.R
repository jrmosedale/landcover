####################################################################################
# Prepare training and validation data from existing data sources
# Data loading
# Class selection
# ID Polygons where no disagreement
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
#library(lwgeom)

# Directories
in.root<-"/Volumes/Pocket_Sam/Data/"
root<-"/Volumes/Pocket_Sam/Data/MapApp/Indicator_data/"
dir_aoi<-"/Users/jonathanmosedale/Rprojects/landcover/masks/"
dir_cehlandcover<-paste0(in.root,"CEH/lcm-2015-vec_1912428/LCM2015_clip_southwestEngland/")
dir_corine<-paste0(in.root,"Corine/clc12_Version_18_5_southwestEngland/")
dir_nateng<-paste0(in.root,"NaturalEngland/")
dir_forest<-paste(in.root,"ForestCom/",sep="")
dir_builtup<-paste(in.root,"OS/OpenLocal/open-map-local_1912424/",sep="")
dir_agri<-paste0(in.root,"Agriculture/RPAgency/CROME_2017_Southwest/")

dir_out<-paste0(in.root,"training_data/")

## FUNCTIONS
# Convert bbbox to sf polygon
sf_from_bbox<-function(polygon_in){
  bb<-st_bbox(polygon_in)
  polygon_out<-st_polygon(list(cbind(c(bb[1],bb[3],bb[3],bb[1],bb[1]),c(bb[2],bb[2],bb[4],bb[4],bb[2]))))
  polygon_out<-st_sfc(polygon_out)
  st_crs(polygon_out)<-st_crs(polygon_in)
  return(polygon_out)
}

#   test<-aoimask

# Define master rasters to be used for landcover determination
#cornwall_land.r<-raster(paste0(root,"cornwall_land_100m.tif"))
#template.r<-raster(ext=extent(cornwall_land.r), res=100, crs="+init=epsg:27700")

####################################################################################
# Load data sources to be used for training data
#
####################################################################################

### Define AOI - use separate mainland IoS masks
# Load buffered Cornwall mainland 15km land buffer MHW shape files:
aoimask<-st_read(paste0(dir_aoi,"cornwall_mainland_MHWpolygon_27700.shp"))
st_crs(aoimask)<-st_crs(27700)
plot(aoimask)
#Could st_simplify mask to speed operations using rmapshaper::ms_simplify (x, keep_shapes=TRUE, keep=?0.1?)??


# CEH dominant landover vector map- already partially clipped to aoi
cehlc<-st_read(paste0(dir_cehlandcover,"LCM2015_clip_southwestEngland.shp"),stringsAsFactors = FALSE)
st_crs(cehlc)<-st_crs(27700)
#cehlc.aoi<-st_intersection(cehlc,sf_from_bbox(aoimask))
###NEW HERE !!!!! ####
sel<-st_intersects(cehlc, aoimask)
cehlc<-cehlc[which(sel==1),]
cehlc.aoi<-st_intersection(cehlc,aoimask)
unique(cehlc.aoi$bhab)
st_write(cehlc.aoi,paste0(dir_out,"cehlc_cornwallMHW500m_27700.shp"),delete_layer = TRUE)

# Corine landcover vector map
corinelc<-st_read(paste0(dir_corine,"clc12_v18_5_clip_southwest.shp"),stringsAsFactors = FALSE)
corinelc27700<-st_transform(corinelc,27700)
sel<-st_intersects(corinelc27700, aoimask)
corinelc.aoi<-corinelc27700[which(sel==1),]
unique(corinelc.aoi$code_12)
# Add key and merge
clc_lookup<-read.csv(paste0(in.root,"Corine/Legend/clc_legend.csv"),sep=";",header=TRUE)
corinelc.aoi<-merge(corinelc.aoi,clc_lookup,by.x= "code_12", by.y="CLC_CODE")
corinelc.aoi<-st_intersection(corinelc.aoi,aoimask)
#corinelc.aoi<-st_intersection(corinelc27700,aoimask)
st_write(corinelc.aoi,paste0(dir_out,"corinelc_cornwallMHW500m_27700.shp"),delete_layer = TRUE)

# NE priority habitats
priorityhab<-st_read(paste(dir_nateng,"PriorityHabitats_SOuth/PHI_v2_1_South.shp",sep=""), stringsAsFactors = FALSE)
st_crs(priorityhab)<-st_crs(27700)
#  ID intersecting polygons then clip
#priorityhab<-st_intersection(priorityhab,sf_from_bbox(aoimask))
sel<-st_intersects(priorityhab, aoimask)
priorityhab<-priorityhab[which(sel==1),]

priorityhab.aoi<-st_intersection(priorityhab, aoimask)
unique(priorityhab.aoi$Main_habit)
st_write(priorityhab.aoi,paste0(dir_out,"priorityhabitat_cornwallMHW500m_27700.shp"),delete_layer = TRUE)

# Use FC forest inventory -  in epsg27700
forests<-st_read(paste0(dir_forest,"National_Forest_Inventory_2016/NATIONAL_FOREST_INVENTORY_ENGLAND_2016_INT.shp"), stringsAsFactors = FALSE)
st_crs(forests)<-st_crs(27700)
sel<-st_intersects(forests, aoimask)
forests<-forests[which(sel==1),]
forests.aoi<-st_intersection(forests, aoimask)
unique(forests.aoi$IFT_IOA)
st_write(forests.aoi,paste0(dir_out,"forests_cornwallMHW500m_27700.shp"),delete_layer = TRUE)

# Crop map - only useful for crop identification for specific year
crops<-st_read(paste0(dir_agri,"SOUTHWEST_20171123.shp"), stringsAsFactors = FALSE)
st_crs(crops)<-st_crs(27700)
sel<-st_intersects(crops, aoimask)
crops<-crops[which(sel==1),]
# crops.aoi<-st_intersection(crops, aoimask) - # too slow !!!
unique(crops.aoi$LUCODE)
st_write(crops.aoi,paste0(dir_out,"crophex_2017_cornwallMHW500m_27700.shp"),delete_layer = TRUE)

# Check pattern of distrib - eg evidence of satellite path effect
#plot(crops.aoi[crops.aoi$LUCODE=="AC27",]$geometry,col="red")
#plot(crops.aoi[crops.aoi$LUCODE=="AC27",]$geometry,col="red")
#plot(crops.aoi[crops.aoi$LUCODE=="AC07",]$geometry,col="yellow",add=TRUE)
#plot(crops.aoi[crops.aoi$LUCODE=="PG01",]$geometry,col="green",add=TRUE)

####################################################################################
### Checl validity of these datasets
####################################################################################
validity<-st_is_valid(cehlc.aoi$geometry)
print(paste("Number of invalid geoms=",length(validity[validity==FALSE])))
# ID invalid geometries and why
invalid<-which(validity==FALSE)
st_is_valid(cehlc.aoi$geometry[invalid],reason=TRUE)
# Try to correct
sf_extSoftVersion()["lwgeom"]
corrected.geoms<-st_make_valid(cehlc.aoi$geometry[invalid])

####################################################################################
# Calculate proportion of different landcovers for each database
####################################################################################
### Load datasets
cehlc.aoi<-st_read(paste0(dir_out,"cehlc_cornwallMHW500m_27700.shp"))
st_crs(cehlc.aoi)<-st_crs(27700)
corinelc.aoi<-st_read(paste0(dir_out,"corinelc_cornwallMHW500m_27700.shp"))
st_crs(corinelc.aoi)<-st_crs(27700)
priorityhab.aoi<-st_read(paste0(dir_out,"priorityhabitat_cornwallMHW500m_27700.shp"))
st_crs(priorityhab.aoi)<-st_crs(27700)
forests.aoi<-st_read(paste0(dir_out,"forests_cornwallMHW500m_27700.shp"))
st_crs(forests.aoi)<-st_crs(27700)
crops.aoi<-st_read(paste0(dir_out,"crophex_2017_cornwallMHW500m_27700.shp"))
st_crs(crops.aoi)<-st_crs(27700)

### CEH
habitats<-unique(cehlc.aoi$bhab)
hab.areas<-rep(0,length(habitats))
names(hab.areas)<-habitats
hab.maxpolygon<-rep(0,length(habitats))
names(hab.maxpolygon)<-habitats

for (habitat in habitats){
  print(habitat)
  habitatpolygons<-cehlc.aoi[cehlc.aoi$bhab==habitat,]
  hab.maxpolygon[habitat]<-max((st_area(habitatpolygons)))
  hab.areas[habitat]<-sum(st_area(habitatpolygons))
}

# Convert from m2 to Ha
hab.areas<-hab.areas/10000
hab.maxpolygon<-round(hab.maxpolygon/10000,digits=3)
# print(hab.areas)
# print(hab.maxpolygon)
totalarea<-sum(hab.areas)
# print(totalarea)

perc_of_total<-round((hab.areas/totalarea)*100,digits=2)
# print(perc_of_total)
# print(round(hab.maxpolygons),digits=1)

# % of non-urban,suburb, arable, imp grassland
seminat_total<-sum(hab.areas[c(3,5:8,10:21)])
perc_of_seminat<-round((hab.areas/seminat_total)*100,digits=2)
perc_of_seminat[c(1,2,4,9)]<-NA
#print(perc_of_seminat)

# Output results
results.df<-data.frame(hab.areas,hab.maxpolygon,perc_of_total,perc_of_seminat)
print(results.df)
write.csv(results.df,file=paste0(dir_out,"CEH_cornwallMHW500m_habitatmix_stats.csv"))

### Corine Landcover
unique(corinelc.aoi$LABEL3)
# Exclude sea and ocean
corinelc.aoi<-corinelc.aoi[corinelc.aoi$LABEL3!="Sea and ocean",]

habitats<-unique(corinelc.aoi$LABEL3)
hab.areas<-rep(0,length(habitats))
names(hab.areas)<-habitats
hab.maxpolygon<-rep(0,length(habitats))
names(hab.maxpolygon)<-habitats

for (habitat in habitats){
  print(habitat)
  habitatpolygons<-corinelc.aoi[corinelc.aoi$LABEL3==habitat,]
  hab.maxpolygon[habitat]<-max((st_area(habitatpolygons)))
  hab.areas[habitat]<-sum(st_area(habitatpolygons))
}

# Convert from m2 to Ha
hab.areas<-hab.areas/10000
hab.maxpolygon<-round(hab.maxpolygon/10000,digits=3)
# print(hab.areas)
# print(hab.maxpolygon)
totalarea<-sum(hab.areas)
#totalarea<-sum(corinelc.aoi$Shape_Area)
# print(totalarea)

perc_of_total<-round((hab.areas/totalarea)*100,digits=2)
# print(perc_of_total)
# print(round(hab.maxpolygons),digits=1)

# % of non-urban,suburb, arable, imp grassland
seminat_total<-sum(hab.areas[c(7,16:29)])
perc_of_seminat<-round((hab.areas/seminat_total)*100,digits=2)
perc_of_seminat[c(1:6,8:15)]<-NA
#print(perc_of_seminat)

# Output results
results.df<-data.frame(hab.areas,hab.maxpolygon,perc_of_total,perc_of_seminat)
print(results.df)
write.csv(results.df,file=paste0(dir_out,"Corine_cornwallMHW500m_habitatmix_stats.csv"))

### Natural England Priority Habitats
habitats<-unique(priorityhab.aoi$Main_habit)
hab.areas<-rep(0,length(habitats))
names(hab.areas)<-habitats
hab.maxpolygon<-rep(0,length(habitats))
names(hab.maxpolygon)<-habitats

for (habitat in habitats){
  print(habitat)
  habitatpolygons<-priorityhab.aoi[priorityhab.aoi$Main_habit==habitat,]
  hab.maxpolygon[habitat]<-max((st_area(habitatpolygons)))
  hab.areas[habitat]<-sum(st_area(habitatpolygons))
}

# Convert from m2 to Ha
hab.areas<-hab.areas/10000
hab.maxpolygon<-round(hab.maxpolygon/10000,digits=3)
# print(hab.areas)
# print(hab.maxpolygon)
totalarea<-sum(hab.areas)
# print(totalarea)

perc_of_total<-round((hab.areas/totalarea)*100,digits=2)
# print(perc_of_total)
# print(round(hab.maxpolygons),digits=1)

# Output results
results.df<-data.frame(hab.areas,hab.maxpolygon,perc_of_total)
print(results.df)
write.csv(results.df,file=paste0(dir_out,"Priority_cornwallMHW500m_habitatmix_stats.csv"))

### Forest inventory
habitats<-unique(forests.aoi$IFT_IOA)
hab.areas<-rep(0,length(habitats))
names(hab.areas)<-habitats
hab.maxpolygon<-rep(0,length(habitats))
names(hab.maxpolygon)<-habitats

for (habitat in habitats){
  print(habitat)
  habitatpolygons<-forests.aoi[forests.aoi$IFT_IOA==habitat,]
  hab.maxpolygon[habitat]<-max((st_area(habitatpolygons)))
  hab.areas[habitat]<-sum(st_area(habitatpolygons))
}

# Convert from m2 to Ha
hab.areas<-hab.areas/10000
hab.maxpolygon<-round(hab.maxpolygon/10000,digits=3)
totalarea<-sum(hab.areas)
perc_of_total<-round((hab.areas/totalarea)*100,digits=2)

# % of non-urban,agri, road water etc, imp grassland
nonforest.types<-c("Agriculture land","Urban","Quarry","Road","River","Open water","Grassland","Other vegetation")
forest.types<-habitats[!(habitats %in% nonforest.types)]
totalforest<-sum(hab.areas[forest.types])
perc_of_forest<-round((hab.areas/totalforest)*100,digits=2)
perc_of_forest[nonforest.types]<-NA
print(perc_of_forest)

# Output results
results.df<-data.frame(hab.areas,hab.maxpolygon,perc_of_total,perc_of_forest)
print(results.df)
write.csv(results.df,file=paste0(dir_out,"Forest_cornwallMHW500m_habitatmix_stats.csv"))


### Crops - mix of types
# Cannot calculate meaningful areas so simple frequency count of different crops
crop.types<-unique(crops.aoi$LUCODE)
crop.freq<-rep(0,length(crop.types))
names(crop.freq)<-crop.types
#hab.maxpolygon<-rep(0,length(crop.types))
#(hab.maxpolygon)<-habitats

for (crop in crop.types){
  print(crop)
  crop.freq[crop]<-length(crops.aoi$LUCODE[crops.aoi$LUCODE==crop])
}
print(crop.freq)
sum.all<-length(crops.aoi$LUCODE)
# freq.agri - without woods, other, water and heathland
nonagri<-c("WO12","NA01","WA01") # NB: HE02 not found
sum.agri<-length(crops.aoi$LUCODE[!( crops.aoi$LUCODE %in% nonagri)])

perc_of_total<-round((crop.freq/sum.all)*100,digits=3)
perc_of_agri<-round((crop.freq/sum.agri)*100,digits=3)
perc_of_agri[nonagri]<-NA

# Output results and add lookup table names
results.df<-data.frame(crop.types,crop.freq,perc_of_total,perc_of_agri)
crop.lookup<-read.csv(paste0(dir_out,"crop__classes.csv"),header=TRUE,sep=",")
results.df<-merge(results.df,crop.lookup,by.x="crop.types",by.y="LUCODE")

print(results.df)
write.csv(results.df,file=paste0(dir_out,"crops_cornwallMHW500m_cropmix_stats.csv"))




####################################################################################
# ID Polygons of interest for training
# For each database used:
# 1 Extract polygons from each database for each training classs
# 2 Check geometriees and correct per database extraction
# 3 Remove duplicates and invalid geometries
# Other stages:
# Merge polygons of same class from different datasets - keep only those areas where all datasets agree
# Difference intersection of different class polygons - remove areas of disagreement
# Optional -ve buffer to remove edges of polygons
# Remove any development areas where likely land change over past 5 yrs
####################################################################################
# Function - prepsf_for_raster
sf_to_raster<-function(shapedata,template.r){
  # Force multipolygons to polygons
  shapedata <- st_cast(shapedata, "POLYGON")
  #Add variable ID holding numeric identifier for each polygon from rownames
  ID<-as.numeric(rownames(shapedata)))
  # Rasterize giving same value to pixels of the same woodland polygon. Non-woodland=NA
  data.r<-rasterize(shapedata,template.r,field=ID)
  return(data.r)
}

# decidwoods
dwoods1<-cehlc.aoi[cehlc.aoi$bhab=="Broadleaf woodland",]
#dwoods2<-corinelc.aoi[corinelc.aoi$LABEL3=="Broad-leaved forest",]
dwoods2<-priorityhab.aoi[priorityhab.aoi$Main_habit=="Deciduous woodland",]
dwoods3<-forests.aoi[forests.aoi$IFT_IOA %in% c("Broadleaved","Mixed mainly broadleaved"),]
dwoods3<-st_cast(dwoods3, "POLYGON")
# Keep only areas that agree across all sources
decidwoods<-st_intersection(dwoods1,dwoods2)
decidewoods<-st_intersection(decidwoods,dwoods3)
decidwoods<-checkvalid(decidwoods)
plot(decidwoods$geometry)
# Exclude any known recent landuse change areas (development zones etc)
# decidwoods<-st_difference(decidwoods,devzones)
# Convert to raster
template.r<-raster(FILEPATHANDNAME)
decidwoods<-sf_to_raster(decidwoods,template.r)


conifwoods

seminatgrass
impgrass

quarries<-

anncrops<-

sanddunes<-


moors
grassmoors
upheath
lowheath
  
####################################################################################
# CREATE RASTER MASKS OF FIXED NETWORKS - roads, watercourses, buildings from which
# models of pixel response to these features can be developed
####################################################################################


####################################################################################
# Calculate % building cover of raster pixels using OS local vector data
# REQUIRES raster template: template.r
####################################################################################
# Calculate from OpenLocal maps from OS
# Uses tiles SX, SW, SV, SS
urbantiles<-vector("list",4)
i<-1
tiles<-c("SX","SW","SS","SV") # Note SV=Isles of Scilly

for (t in tiles){
  buildings<-st_read(dir_builtup,paste0(t,"_Building"))
  st_crs(buildings)<-st_crs(27700)
  buildings<-st_intersection(buildings, aoimask)
  # rasterize and record % of cell = builtup
  r<-rasterize(buildings,template.r,getCover=TRUE)
  #filename<-paste(dir_wgsmap,"urban_temp_r_",t,".tif",sep="")
  #print(paste("Completed:",t))
  #writeRaster(r,file=filename)
  urbantiles[[i]]<-r
  plot(r,main=t)
  i<-i+1
  print(i)
}
urbanmap.r<-mosaic(urbantiles[[1]],urbantiles[[2]],urbantiles[[3]],fun="mean")


####################################################################################
# Load road data and create rasters of network
# REQUIRES raster template
####################################################################################
MW<-st_sf(st_sfc(crs=27700)) ; st_crs(MW)$proj4string<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs"
Aroads<-st_sf(st_sfc(crs=27700)) ; st_crs(Aroads)$proj4string<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs"
Broads<-st_sf(st_sfc(crs=27700)) ; st_crs(Broads)$proj4string<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs"
MinorRoads<-st_sf(st_sfc(crs=27700)) ; st_crs(MinorRoads)$proj4string<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs"
DCroads<-(st_sfc(crs=27700)) ; st_crs(DCroads)$proj4string<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs"


for (n in c("SS","SV","SX","SW")){
  print(n)
  roads.st<-st_read(paste(in.root,"OS/open-roads_2132181/",n,"_RoadLink.shp", sep="") )
  st_crs(roads.st<-st_crs(27700))
  if (n=="SS") Allroads<-roads.st else Allroads<-rbind(Allroads,roads.st)
  if (n=="SS") Aroads<-roads.st[roads.st$function.== "A Road",] else Aroads<-rbind(Aroads,roads.st[roads.st$function.== "A Road",])
  if (n=="SS") Broads<-roads.st[roads.st$function.== "B Road",] else Broads<-rbind(Broads,roads.st[roads.st$function.== "B Road",])
  if (n=="SS") MinorRoads<-roads.st[roads.st$function.== "Minor Road",] else MinorRoads<-rbind(MinorRoads,roads.st[roads.st$function.== "Minor Road",])
  if (n=="SS") DCroads<-roads.st[roads.st$formOfWay== "Collapsed Dual Carriageway",] else DCroads<-rbind(DCroads,roads.st[roads.st$formOfWay== "Collapsed Dual Carriageway",])
}
plot(Broads$geometry)
plot(Aroads$geometry,add=T,col="red")
plot(DCroads$geometry, add=T,col="magenta")
plot(MinorRoads,add=T,col="blue")

####################################################################################
# Load watercourses data and create rasters of network
# REQUIRES raster template
####################################################################################
rivers<-st_read(paste(in.root,"OS/open-rivers_2132182/WatercourseLink.shp",sep=""))
st_crs(rivers)<-st_crs(27700)
rivers.aoi<-st_intersection(rivers, aoimask)
#plot(rivers.aoi$geometry)
st_write(rivers.aoi,paste0(dir_out,"rivers_aoi_27700.shp"))

rivers.r<-rasterize(as(st_zm(rivers.aoi),'Spatial'),template.r)
rivers.r<-calc(rivers.r,fun=function(x){ifelse(!is.na(x),1,0)}) # presence=1, absence=0
plot(rivers.r,col="blue")
writeRaster(rivers.r,filename=paste(root,"watercourses.tif",sep=""),overwrite=T)
