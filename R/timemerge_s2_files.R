# Merge two S2 tif files from different times to a single multiband tif
ndvi<-function(nir,red){
  (nir-red)/(nir+red)
}

s2.root<-"/Users/jm622/apps/s2_data/"

# Load S2 optical bands for two dates
s2_june.s<-brick(paste(s2.root,"wadebridge_10m_WGS84_S2A_MSIL2A_20170617_T30UUB.tif",sep=""))
bandnum<-as.character(c(1:12))
names(s2_june.s)<-paste("Band_",bandnum,"_June",sep="")
s2_june.s<-raster::subset(s2_june.s,c(2,3,4),drop=FALSE)

s2_april.s<-brick(paste(s2.root,"wadebridge_10m_WGS84_S2A_MSIL2A_20170408_T30UUB.tif",sep=""))
bandnum<-as.character(c(1:12))
names(s2_april.s)<-paste("Band_",bandnum,"_April",sep="")
s2_april.s<-raster::subset(s2_april.s,c(2,3,4,5,8,11),drop=FALSE)

# Resample june on april raster 
s2_june2.s<-resample(s2_june.s,s2_april.s)

ndvi_apr<-ndvi(s2_april.s[["Band_8_April"]],s2_april.s[["Band_2_April"]])
ndvi_jun<-ndvi(s2_june2.s[["Band_8_June"]],s2_june2.s[["Band_2_June"]])


compareRaster(s2_april.s,s2_june2.s,ndvi_apr,ndvi_jun)
r<-stack(s2_april.s,ndvi_apr,s2_june2.s,ndvi_jun)
names(r)<-c(names(s2_april.s),"ndvi_April",names(s2_june2.s),"ndvi_June")

fileout<-paste(s2.root,"s2_wadebridge_april_june.tif",sep="")
writeRaster(r,fileout,overwrite=TRUE)


######
# Apply edge filter
fy<-matrix(c(1,0,-1,2,0,-2,1,0,-1),nrow=3)
fx<-matrix(c(1,2,1,0,0,0,-1,-2,-1),nrow=3)

for (n in 1:14){
r.y<-focal(raster(r,n),fy)
r.x<-focal(raster(r,n),fx)
edge<-sqrt(r.y^2+r.x^2)
if (n==1) edge.s<-brick(edge,nl=1)
if (n>1) edge.s<-addLayer(edge.s,edge)
#plot(edge)
}

fileout<-paste(s2.root,"s2_wadebridge_april_june_edgeenhanced.tif",sep="")
writeRaster(test2,file=paste0(s2.root,"wadebridge_3band.tif"),overwrite=TRUE)

# Try some cluster analyses


Res<-kmeans(na.omit(getValues(r)), centers = 10, iter.max = 500, nstart = 3, algorithm="Lloyd")
