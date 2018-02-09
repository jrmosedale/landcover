# Edge detection using package imager

library(imager)
library(raster)
library(mapview)

filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_1.png"
rgb<-load.image(filein)
plot(rgb)

R(rgb) %>% hist(main="Red channel values picture")

# Edge detection - 
dx <- imgradient(rgb,"x")
dy <- imgradient(rgb,"y")
grad.mag <- sqrt(dx^2+dy^2)
plot(grad.mag,main="Gradient magnitude")
#or...
imgradient(rgb,"xy") %>% enorm %>% plot(main="Gradient magnitude (again)")

r<-as.raster(grad.mag)
#sel<-which(r=="#000000")
#r[sel]<-NA
rgb.m<-col2rgb(r)
template<-ndvi_apr
red.out<-setValues(template,rgb.m[1,]) 
green.out<-setValues(template,rgb.m[2,]) 
blue.out<-setValues(template,rgb.m[3,]) 
rgb.b<-brick(red.out,green.out,blue.out)
plotRGB(rgb.b) # RGB brick 0-255 for 3 layers

# Display edges as map layer
# Create binary edges
edges<-overlay(raster(rgb.b,1),raster(rgb.b,2),raster(rgb.b,3),fun=function(x,y,z){ifelse(x==0&y==0&z==0,0,1) })
plot(edges)
################
# Carry out on individual ndvi and on difference values
s1.root<-"apps/s1_data/"
s2.root<-"apps/s2_data/"
# Load S2 optical bands for two dates
s2_june.s<-brick(paste(s2.root,"wadebridge_10m_WGS84_S2A_MSIL2A_20170617_T30UUB.tif",sep=""))
bandnum<-as.character(c(1:12))
names(s2_june.s)<-paste("Band_",bandnum,sep="")
s2_june.s<-raster::subset(s2_june.s,c(2,3,4,5,8,11),drop=FALSE)
s2_april.s<-brick(paste(s2.root,"wadebridge_10m_WGS84_S2A_MSIL2A_20170408_T30UUB.tif",sep=""))
bandnum<-as.character(c(1:12))
names(s2_april.s)<-paste("Band_",bandnum,sep="")
s2_april.s<-raster::subset(s2_april.s,c(2,3,4,5,8,11),drop=FALSE)

# Calculate ndvi and difference
ndvi<-function(nir,red){
  (nir-red)/(nir+red)
}

ndvi_apr<-ndvi(s2_april.s[["Band_8"]],s2_april.s[["Band_2"]])
ndvi_jun<-ndvi(s2_june.s[["Band_8"]],s2_june.s[["Band_2"]])
# resample to same raster
ndvi_jun_rsmp<-resample(ndvi_jun,ndvi_apr)
ndvi_dif<-ndvi_jun_rsmp-ndvi_apr


#### Display as RGB
r.s<-brick(ndvi_apr,ndvi_jun_rsmp,ndvi_dif) # create three band 'rgb' brick
# Try to conver to rgb raster 
r.scale<-stack()
for (n in 1:3){
  mx<-cellStats(raster(r.s,n),max,rm.na=TRUE)
  mn<-cellStats(raster(r.s,n),min,rm.na=TRUE)
  r<-((raster(r.s,n)-mn)/(mx-mn))*255
  r.scale<-addLayer(r.scale,r)
}
image(r.scale)
plotRGB(r.scale)
# Plot rgb
plotRGB(r.s,1,2,3,stretch="hist") # stretch="lin" creates darker image

# Mask out non-vegetative
plot(raster(r.s,1),col=grey(1:100/100),main="NDVI April")
plot(raster(r.s,2),col=grey(1:100/100),main="NDVI JUne")
plot(raster(r.s,3),col=grey(1:100/100),main="June-Apr")
plot(abs(raster(r.s,3)),col=grey(1:100/100),main="Absolute difference")

maxndvi.r<-calc(r.s,fun=max)
plot(maxndvi.r,col=grey(1:100/100),main="Max ndvi")
minndvi.r<-calc(r.s,fun=min)
plot(minndvi.r,col=grey(1:100/100),main="Min ndvi")


# Test out masks based on max ndvi
m<-maxndvi.r
m[m < 0.5] <- NA
plot(m,main="Mask max NDVI<0.5")

# Plot rgb as png - full resolution for edge detection using imager package - PROBLEM with dimensions / pixels
png(file="/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_dif_new.png",height=nrow(r.s), width=ncol(r.s)) # prob = large white space
#tiff(file="/Users/jm622/Sentinel/Sentinel-2/Outputs/test.tiff")
plotRGB(r.s,1,2,3,stretch="hist",maxpixels=ncell(raster(r.s,1)) ) 
dev.off()

# EDGE detection of RGB png
#filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_dif.png"
filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_dif_new.png"
rgb<-load.image(filein)
plot(rgb)

imgradient(rgb,"xy") %>% enorm %>% plot(bg="White")
#res<-imgradient(rgb,"xy")
dx <- imgradient(rgb,"x",scheme=5)
dy <- imgradient(rgb,"y",scheme=5)
grad.mag <- sqrt(dx^2+dy^2)
plot(grad.mag,main="Gradient magnitude")

# Writing reading png files see: https://cran.r-project.org/web/packages/png/png.pdf 
# PLot to png file:
png(file = "/Users/jm622/Sentinel/Sentinel-2/Outputs/testplot.png", width= 1595, height= 1063, units="px")
imgradient(rgb,"xy") %>% enorm %>% plot(axes = F)
dev.off()


# EDGE detection of Single NDVI band
png(file="/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_apr_img.png")
image(ndvi_apr)
dev.off()
png(file="/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_apr_img.png")
image(ndvi_jun_2)
dev.off()
png(file="/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_dif_img.png")
image(ndvi_dif)
dev.off()


filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_dif_img.png"
ndvi<-load.image(filein)
plot(ndvi)
imgradient(ndvi,"xyz") %>% enorm %>% plot()
#res<-imgradient(rgb,"xy")


##############################
# K mean clustering of JPEG image based on RGB
# REf: https://www.r-bloggers.com/r-k-means-clustering-on-an-image/ 
library(jpeg)
library(ggplot2)
filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb.jpeg"
img <- readJPEG(filein)
# Obtain the dimension
imgDm <- dim(img)

# Assign RGB channels to data frame
imgRGB <- data.frame(
  x = rep(1:imgDm[2], each = imgDm[1]),
  y = rep(imgDm[1]:1, imgDm[2]),
  R = as.vector(img[,,1]),
  G = as.vector(img[,,2]),
  B = as.vector(img[,,3])
)

ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = rgb(imgRGB[c("R", "G", "B")])) +
  labs(title = "Original Image: Colorful Bird") +
  xlab("x") +
  ylab("y")

# Perform clustering
kClusters <- 10
kMeans <- kmeans(imgRGB[, c("R", "G", "B")], centers = kClusters)
kColours <- rgb(kMeans$centers[kMeans$cluster,])

# Plot clustered image
ggplot(data = imgRGB, aes(x = x, y = y)) + 
  geom_point(colour = kColours) + theme_void()
  plotTheme()

# Polygonize result?  
# create raster of clusters - requires performing cluster on orig raster dervied res data
#cluster.r<-raster(r.s,1)
#cluster.r<-setValues(cluster.r,kMeans$cluster)
#########################

# Writing reading png files see: https://cran.r-project.org/web/packages/png/png.pdf 
# PLot to png file:
png(file = "/Users/jm622/Sentinel/Sentinel-2/Outputs/testplot.png", bg = "transparent", width= 1595, height= 1063, units="px")
imgradient(rgb,"xy") %>% enorm %>% plot(axes = F,useRaster=F)
dev.off()





##### PLot raster without borders, frame etc
r<-ndvi_apr
png(file="",height=nrow(r), width=ncol(r))
plot(r, legend=FALSE)

## Overlay road network?

# PLot leaflet raster image
rgbcol<-RGB_colors(r.s,1,2,3) 

# create rgb raster
#fileout<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_1"
#rgb.r<-RGB(r.s,filename=fileout,col=rgbcol)


leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11)  %>%
  addProviderTiles("OpenStreetMap.Mapnik")  %>%  
  #addProviderTiles("OpenTopoMap", group="Open Topological Map")  %>%   
  addScaleBar() %>%
  addRasterImage(x=r.s[[1]],colors=rgbcol, group="ndvi",
                 opacity=0.8) %>% 
 addLayersControl(
   overlayGroups = c("ndvi"),
   options = layersControlOptions(collapsed = TRUE)
                   ) 
  )








# adimpro package
library(adimpro)
filein<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_full.tiff"

read.image(filein)



# References:
# https://grass.osgeo.org/grass72/manuals/addons/i.edge.html 