library(raster)
library(sf)
library(rgeos)
library(sp)
library(gdalUtils)
######################################################
# Mosaic March-April 2017
######################################################
dir_10m<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170304Mosaic/10m_bands/"
dir_in<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170304Mosaic/Output_Tiles/"

# list.files(dir_in)
#UVA0408.orig<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVA_20170408T113407_10mbands.tif"))
UVA0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVA_edgemasks_msk10m.tif"))
UVA0326.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170326T112111_N0204_R037_T30UVA_20170326T112108_10mbands.tif"))
UVB0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVB_20170408T113407_10mbands.tif"))
UUA0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UUA_20170408T113407_10mbands.tif"))
UUB0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UUB_20170408T113407_10mbands.tif"))
# Create mosaic of tiles - using mean for overlapping pixels
mosaic10m.r<-mosaic(UVA0408.r, UVA0326.r, UVB0408.r, UUA0408.r, UUB0408.r, fun=mean)
# load prev mosaic performed in SNAP
mosaic0304.r<-brick(paste0(dir_in,"Cornwall_2017_0304_UUA_UUB_UVAx2_UVB_msizemosaic_blend_10mbands.tif"))


# Load shape file mask as spdf
dir_aoi<-"masks/"
aoimask<-st_read(paste0(dir_aoi,"Cornwall_mainland_buffer500m_WGS84_EPSG4326.shp"))
aoimask<-as(st_union(aoimask),"Spatial")
plot(aoimask)

# Reproject then crop and mask raster - WGS UTM30 projection
aoimask<-spTransform(aoimask,crs(mosaic10m.r))
cornwall_0304_10m.r <- crop(mosaic10m.r, extent(aoimask))
cornwall_0304_10m.r <- mask(cornwall_0304_10m.r, aoimask)
plotRGB(cornwall_0304_10m.r,r=3,g=2,b=1, stretch="hist")
names(cornwall_0304_10m.r)<-c("B2","B3","B4","B8")


dir_out<-"/Volumes/Sentinel_Store/Sentinel/Sentinel_2/tif_data/"
writeRaster(cornwall_0304_10m.r,paste0(dir_out,"cornwall_2017_0326-0408_10mbands_500mbuffer.tif"))
dir_out<-"rasters/"
writeRaster(cornwall_0304_10m.r,paste0(dir_out,"cornwall_2017_0326-0408_10mbands_500mbuffer.tif"),overwrite=TRUE)

######################################################
# Other resolutions
######################################################
#list.files(dir_in)
#UVA0408.orig<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVA_20170408T113407_10mbands.tif"))
UVA0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVA_edgemasks_msk20m.tif"))
UVA0326.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170326T112111_N0204_R037_T30UVA_20170326T112108_20mbands.tif"))
UVB0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UVB_20170408T113407_20mbands.tif"))
UUA0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UUA_20170408T113407_20mbands.tif"))
UUB0408.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170408T113321_N0204_R080_T30UUB_20170408T113407_20mbands.tif"))




############################################################################################################
# Mosaic May-June 2017
############################################################################################################
dir_in<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170506Mosaic/Outputs/"

# Alternative method see: https://stackoverflow.com/questions/5413188/reading-csv-files-in-a-for-loop-and-assigning-dataframe-names
list.files(dir_in)

UVA0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UVA_20170617T113319_10mbands.tif"))
UVA0525.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434_10mbands.tif"))
UVB0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UVB_20170617T113319_10mbands.tif"))
UUA0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UUA_20170617T113319_10mbands.tif"))
UUB0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UUB_20170617T113319_10mbands.tif"))
UUB0614.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170614T112111_N0205_R037_T30UUB_20170614T112422_10mbands.tif"))

plotRGB(UUB0617.r,r=3,g=2,b=3,stretch="hist")


# 1. First correct for cloud cover in UUB0617 by substituting pixels from UUB0614 - cloud data from Cloud_S2A20170617_UUB.txt
cloudarea<-"POLYGON ((-4.475301616674273 50.70668946830429, -4.482837792622376 50.70609020225258, -4.484298656991272 50.70593220868248, -4.486462961508991 50.706619615564485, -4.488701562676432 50.706087407169, -4.4912736883146955 50.70541148876264, -4.491162462039852 50.70190542368076, -4.4932357251929 50.69972941927419, -4.49104897704235 50.698327436946705, -4.49478717033357 50.69534315419874, -4.495976761872732 50.69374951893857, -4.4945627990675705 50.691834039963666, -4.492022666542895 50.689937462969304, -4.491981740369842 50.68864740808134, -4.490149667082334 50.687740011501376, -4.491222045596311 50.68600852076538, -4.4919604798533115 50.68442069551814, -4.490353651750294 50.68351041844625, -4.488021878291151 50.684614947385654, -4.4857729274472655 50.68478753748561, -4.484029190039146 50.686671425617725, -4.480772883032617 50.68707258725723, -4.479145716480852 50.68909881641934, -4.477040630166358 50.690267696923925, -4.47714638046452 50.69363444671848, -4.47688710421505 50.69614243900506, -4.475784765679349 50.69694333812448, -4.474739070503186 50.69595379226471, -4.47090996224763 50.69607412710001, -4.4700770264006975 50.70188547492053, -4.472016817460333 50.70622735868576, -4.472016817460333 50.70622735868576, -4.475301616674273 50.70668946830429))"
cloudarea2<-" POLYGON ((-4.496099550636428 50.683436797762575, -4.4963911323978065 50.68551057378411, -4.5017387279213255 50.687087616904385, -4.505203969478624 50.686184025739244, -4.506614041717833 50.68444802844678, -4.5079635492895775 50.68435862597002, -4.507726644361606 50.68400644385487, -4.5070417484404155 50.68372750723336, -4.508168020940733 50.68371293761048, -4.508515526053284 50.683996235292625, -4.508742911642005 50.68406524061986, -4.509187794027804 50.68443271484834, -4.509448983839297 50.68464517867156, -4.510222581645255 50.685012887823355, -4.513069674755909 50.6840046496891, -4.513060734493575 50.68109983058769, -4.506790615581999 50.6809697184578, -4.505635398334836 50.67926237367853, -4.501448536498784 50.67807977071897, -4.501746947924182 50.67947443102462, -4.502465531402974 50.680755750891834, -4.50078264672135 50.68109670777354, -4.500392173909208 50.6821270057786, -4.497013246585139 50.68238630460786, -4.497013246585139 50.68238630460786, -4.496099550636428 50.683436797762575))"
cloudarea3<-"  POLYGON ((-4.495695864964595 50.704684807374015, -4.488550192082706 50.7069257407683, -4.48614278298465 50.70924531772287, -4.4827027011463025 50.71101138998477, -4.4817152075189535 50.71546225744081, -4.492822616060551 50.71718220482221, -4.496339235419371 50.71427267293046, -4.502991349616033 50.710679605457244, -4.50480900832021 50.707575859213584, -4.503597022650248 50.704942894562755, -4.502739539787604 50.70280448996015, -4.498472351959866 50.703358569930934, -4.4973850886562765 50.701083680051504, -4.494346655827739 50.70126657166187, -4.494354451780829 50.705061755045065, -4.494354451780829 50.705061755045065, -4.495695864964595 50.704684807374015))"

cloud<-readWKT(cloudarea); proj4string(cloud)<-CRS("+init=epsg:4326")
cloud2<-readWKT(cloudarea2); proj4string(cloud2)<-CRS("+init=epsg:4326")
cloud3<-readWKT(cloudarea3); proj4string(cloud3)<-CRS("+init=epsg:4326")
clouds<-union(cloud,union(cloud2,cloud3))

# Set crs of polygons
clouds<-spTransform(clouds, crs(UUB0617.r))

# Overlay plots to check correct
plotRGB(crop(UUB0617.r,extent(clouds)),r=3,g=2,b=3,stretch="hist")
plot(clouds,add=TRUE,col="red")

# replace values of every band using rasterized mask
cloud.msk<-rasterize(clouds,UUB0617.r)
aoi.e<-extent(clouds)
notcloudy<-mask(UUB0617.r,cloud.msk,inverse=TRUE)
plot(crop(notcloudy,aoi.e))
UUBfinal<-merge(notcloudy,UUB0614.r)
plotRGB(crop(UUBfinal,aoi.e),r=3,g=2,b=3,stretch="hist")

# Compare before and after
par(mfrow=c(1,2))
plotRGB(crop(UUB0617.r,aoi.e),r=3,g=2,b=3,stretch="hist")
plotRGB(crop(UUBfinal,aoi.e),r=3,g=2,b=3,stretch="hist")


# 2. Create mosaic of tiles - using mean for overlapping pixels
# Compare UVA tiles to be used
par(mfrow=c(1,2))
e<-extent(399960,430000,5570000,5600040)
plotRGB(crop(UVA0617.r,e),r=3,g=2,b=3,stretch="hist")
plotRGB(crop(UVA0525.r,e),r=3,g=2,b=3,stretch="hist")

# Mosaic
mosaic10m.r<-mosaic(UVA0617.r, UVA0525.r, UVB0617.r, UUA0617.r, UUBfinal,fun=mean)


# 3. Load Cornwall shape file mask as spdf
dir_aoi<-"masks/"
aoimask<-st_read(paste0(dir_aoi,"Cornwall_mainland_buffer500m_WGS84_EPSG4326.shp"))
aoimask<-as(st_union(aoimask),"Spatial")
plot(aoimask)

# 4. Reproject then crop and mask raster - WGS UTM30 projection
#dir_out<-"rasters/"
aoimask<-spTransform(aoimask,crs(mosaic10m.r))
cornwall_0506_10m.r <- crop(mosaic10m.r, extent(aoimask))
cornwall_0506_10m.r <- mask(cornwall_0506_10m.r, aoimask)
par(mfrow=c(1,1))
plotRGB(cornwall_0506_10m.r,r=3,g=2,b=1, stretch="hist")
names(cornwall_0506_10m.r)<-c("B2","B3","B4","B8")


dir_out<-"/Volumes/Sentinel_Store/Sentinel/Sentinel_2/tif_data/"
writeRaster(cornwall_0506_10m.r,paste0(dir_out,"cornwall_2017_0525-0617_10mbands_500mbuffer.tif"),overwrite=TRUE)
dir_out<-"rasters/"
writeRaster(cornwall_0506_10m.r,paste0(dir_out,"cornwall_2017_0525-0617_10mbands_500mbuffer.tif"),overwrite=TRUE)

##########################
### Repeat for other resolutions
##########################
dir_in<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170506Mosaic/Outputs/"

UVA0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UVA_20170617T113319_20mbands.tif"))
UVA0525.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170525T112121_N0205_R037_T30UVA_20170525T112434_20mbands.tif"))
UVB0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UVB_20170617T113319_20mbands.tif"))
UUA0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UUA_20170617T113319_20mbands.tif"))
UUB0617.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170617T113321_N0205_R080_T30UUB_20170617T113319_20mbands.tif"))
UUB0614.r<-brick(paste0(dir_in,"S2A_MSIL2A_20170614T112111_N0205_R037_T30UUB_20170614T112422_20mbands.tif"))

# Overlay plots to check correct
clouds<-spTransform(clouds, crs(UUB0617.r))

par(mfrow=c(1,1))
plot(crop(raster(UUB0617.r,layer=1),extent(clouds)))
plot(clouds,add=TRUE,col="red")

# replace values of every band using rasterized mask
cloud.msk<-rasterize(clouds,UUB0617.r)
aoi.e<-extent(clouds)
notcloudy<-mask(UUB0617.r,cloud.msk,inverse=TRUE)
plot(crop(notcloudy,aoi.e))
UUBfinal<-merge(notcloudy,UUB0614.r)
plotRGB(crop(UUBfinal,aoi.e),r=3,g=2,b=3,stretch="hist")

# Compare before and after - not great!!
par(mfrow=c(1,2))
plotRGB(crop(UUB0617.r,aoi.e),r=3,g=2,b=3,stretch="hist")
plotRGB(crop(UUBfinal,aoi.e),r=3,g=2,b=3,stretch="hist")

# 2. Create mosaic of tiles - using mean for overlapping pixels
mosaic20m.r<-mosaic(UVA0617.r, UVA0525.r, UVB0617.r, UUA0617.r, UUBfinal,fun=mean)

# 3. Use same Cornwall shape file mask

# 4. Reproject then crop and mask raster - WGS UTM30 projection
#dir_out<-"rasters/"
aoimask<-spTransform(aoimask,crs(mosaic20m.r))
cornwall_0506_20m.r <- crop(mosaic20m.r, extent(aoimask))
cornwall_0506_20m.r <- mask(cornwall_0506_20m.r, aoimask)
names(cornwall_0506_20m.r)<-c("B5","B6","B7","B8A","B11","B12")
# Plot
par(mfrow=c(1,1))
plotRGB(cornwall_0506_20m.r,r=3,g=2,b=1, stretch="hist")

# Write rasters
dir_out<-"/Volumes/Sentinel_Store/Sentinel/Sentinel_2/tif_data/"
writeRaster(cornwall_0506_20m.r,paste0(dir_out,"cornwall_2017_0525-0617_20mbands_500mbuffer.tif"))
dir_out<-"rasters/"
writeRaster(cornwall_0506_20m.r,paste0(dir_out,"cornwall_2017_0525-0617_20mbands_500mbuffer.tif"))





##########################
# NOTES
##########################
# if you have many RasterLayer objects in a list
# you can use do.call:
x <- list(r1, r2)
# add arguments such as filename
# x$filename <-
'
test.tif
'
m <- do.call(merge, x)
