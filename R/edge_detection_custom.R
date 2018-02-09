# Custom edge detection - ref: 
# Prepare mask from ndvi values
r.s<-brick(ndvi_apr,ndvi_jun_rsmp,ndvi_dif) # create three band 'rgb' brick
maxndvi.r<-calc(r.s,fun=max)
minndvi.r<-calc(r.s,fun=min)
m<-maxndvi.r
m[m < 0.5] <- NA
plot(m,main="Mask max NDVI<0.5")

# Load stretched rgb of ndvi layers
image.s<-brick("/Users/jm622/Sentinel/Sentinel-2/Outputs/ndvi_rgb_full.tiff") # from rgb file

result<-raster(image.s,1)
result<-setValues(result,rep(0,ncell(result)))

x<-matrix(c(1,0,-1,1,0,-1,1,0,-1),nrow=3)
y<-matrix(c(1,1,1,0,0,0,-1,-1,-1),nrow=3)


for (n in 1:3){
  res.x<-focal(raster(image.s,n),w=x)
  res.y<-focal(raster(image.s,n),w=y)
  res<-res.x+res.y
  #plot(res.y+res.x,col=grey(1:100/100),main=n)
  result<-result+res
}
#plot(abs(result),col=rev(grey(1:100/100))) # for ndvi values
plot(sqrt(abs(result)),col=rev(grey(1:100/100))) # for rgb based edges

# Set all edges to same value - 
# try threshold values of 0.1-0.25 for ndvi based edges
edges<-calc(result,fun=function(x){ifelse(abs(x)>0.15,1,0)})
plot(edges,col=rev(grey(1:100/100)))
# try threshold values of 5-15 for rgb
edges<-calc(sqrt(abs(result)),fun=function(x){ifelse(abs(x)>14,1,0)})
plot(edges,col=rev(grey(1:100/100)))

edges2<-calc(edges,fun=function(x){ifelse(is.na(x),NA,x)})
#plotRGB(rgb)
plot(edges2,col=rev(grey(1:100/100)),na.col="transparent",add=T)

# project ready for mapping
edgvals<-getValues(edges2)
template<-ndvi_apr
edges.r<-setValues(template,edgvals)
plot(crop(edges.r,ndvi_apr))

# Perhaps try another edge detection?!
# OR SMOOTHING algorithm - speckle reduction
res.x<-focal(edges,w=x)
res.y<-focal(edges,w=y)
res<-res.x+res.y
plot(abs(res.y+res.x),col=rev(grey(1:100/100)))
