library(raster)
library(sf)
dir_10m<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170304Mosaic/10m_bands/"
dir_in<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-2/20170304Mosaic/Output_Tiles/"

#list.files(dir_in)
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
names(cornwall_0304_10m.r)<-c("B2","B3","B4","B8A")


dir_out<-"/Volumes/Sentinel_Store/Sentinel/Sentinel_2/tif_data/"
writeRaster(cornwall_0304_10m.r,paste0(dir_out,"cornwall_2017_0326-0408_500mbuffer.tif"))
dir_out<-"rasters/"
writeRaster(cornwall_0304_10m.r,paste0(dir_out,"cornwall_2017_0326-0408_500mbuffer.tif"))

#  dir_out<-"rasters/";  cornwall_0304_10m.r<-brick(paste0(dir_out,"cornwall_2017_0326-0408_500mbuffer.tif"))

# Create merged UVA tile
UVAnew.r<-mosaic(UVA0408.r, UVA0326.r, fun=mean)
UVAnew2.r<-merge(UVA0408.r, UVA0326.r, filename=paste0(dir_10m,"UVA0304new2"))

UVAland<-crop(UVAnew.r,extent(400000,440000,5575000,5600000))
UVAland2<-crop(UVAnew2.r,extent(400000,440000,5575000,5600000))

plot(UVAland,1)

plotRGB(UVAland,r=3,g=2,b=1, stretch="hist",main="UVAnew.r")
plotRGB(UVAland2,r=3,g=2,b=1, stretch="hist",main="")

plotRGB(crop(UVA0408.r,extent(400000,440000,5575000,5600000)),r=3,g=2,b=1, stretch="hist")
plotRGB(crop(UVA0326.r,extent(400000,440000,5575000,5600000)),r=3,g=2,b=1, stretch="hist")
plotRGB(crop(mosaic0304.r,extent(400000,440000,5575000,5600000)),r=3,g=2,b=1, stretch="hist")
plotRGB(mosaic0304.r,r=3,g=2,b=1, stretch="hist")


# Results
# mosaic of cornwall and individual tiles = dif crs - latter = UTM 30 projection cf to WGS84

# reproject tiles to WGS
UVA.WGS<-projectRaster(UVAnew.r,mosaic0304.r)
plotRGB(UVA.WGS,r=3,g=2,b=1, stretch="hist")




# Tile a set of files in same directory

in_filenames<-c("S2A_MSIL2A_20170408T113321_N0204_R080_T30UUA_20170408T113407_10mbands.tif",
           "S2A_MSIL2A_20170408T113321_N0204_R080_T30UUB_20170408T113407_10mbands.tif",
           "S2A_MSIL2A_20170408T113321_N0204_R080_T30UVB_20170408T113407.tif",
           "S2A_MSIL2A_20170408T113321_N0204_R080_T30UVA_20170408T113407_10mbands_msk.tif",
           "S2A_MSIL2A_20170326T112111_N0204_R037_T30UVA_20170326T112108_10mbands.tif"
           )
in_filenames<-paste0(dir_10m,in_filenames)

UUA0408<-brick(in_filenames[1])
UUB0408<-brick(in_filenames[2])
UVA0408<-brick(in_filenames[3])
UVA0326<-brick(in_filenames[4])

cornwall_mosaic_2017_0304<-mosaic(UUA0408, UUB0408,UVA0408,UVA0326,fun=mean)

writeRaster(cornwall_mosaic_2017_0304,filename=paste0(dir_10m,"cornwall_mosaic_2017_0304.tif",overwrite=TRUE))



# if you have many RasterLayer objects in a list
# you can use do.call:
x <- list(r1, r2)
# add arguments such as filename
# x$filename <-
'
test.tif
'
m <- do.call(merge, x)