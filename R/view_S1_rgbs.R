### Test R processing of S1 images 
# macpro dir
s1.root<-"/Users/jm622/Sentinel/Sentinel-1/simple_classif_methods/"

s1.s<-stack(paste(s1.root,"April_July_Stack.tif",sep=""))

# Band names of input
names(s1.s)<-c("gam_VH_040417","gam_VV_040417","gam_VH_040817","gam_VV_040817",
              "gam_VH_250717","gam_VV_250717","gam_VH_280717","gam_VV_280717")

# Calculate means for April and July (each of asc and desc image)
r.s<-stack()
r.s<-stack(r.s,mean(s1.s[[1]],s1.s[[3]]) )
r.s<-addLayer(r.s,mean(s1.s[[2]],s1.s[[4]]))
r.s<-addLayer(r.s,mean(s1.s[[5]],s1.s[[7]]))
r.s<-addLayer(r.s,mean(s1.s[[6]],s1.s[[8]]))

names(r.s)<-c("VH_0417","VV_0417","VH_0717","VV_0717")

# Calculate VV/VH bands - alternative is VV-VH
r.s<-addLayer(r.s,(r.s[[2]]-r.s[[1]]) )
r.s<-addLayer(r.s,(r.s[[4]]-r.s[[3]]) )
names(r.s)<-c("VH_0417","VV_0417","VH_0717","VV_0717","VV/VH_april","VV/VH_july")

# Calculate VV-VHjuly - VV-VHapril  bands
r.s<-addLayer(r.s,(r.s[[6]]-r.s[[5]]) )
names(r.s)<-c("VH_0417","VV_0417","VH_0717","VV_0717","VV/VH_april","VV/VH_july","JulyVV.VH_minus_AprilVV.VH")

# Add VHjuly-VHapril
r.s<-addLayer(r.s,(r.s[[3]]-r.s[[1]]) )
names(r.s)<-c("VH_0417","VV_0417","VH_0717","VV_0717","VV/VH_april","VV/VH_july","JulyVV.VH_minus_AprilVV.VH","JulyVH_minus_AprilVH")


for (n in 1:nlayers(r.s)){
  print(cellStats(raster(r.s,n),range))
  #print(paste("log values:",cellStats(log(raster(r.s,n)),range)))
}


grayscale_colors <- gray.colors(100,            # number of different color levels 
                                start = 0,    # how black (0) to go
                                end = 1,      # how white (1) to go
                                gamma = 2.2,    # correction between how a digital 
                                # camera sees the world and how human eyes see it
                                alpha = NULL)   #Null=colors are not transparent
plot(raster(r.s,1 ), 
     col=grayscale_colors, 
     axes=FALSE)

plot(log(raster(r.s,1) ), 
     col=grayscale_colors, 
     axes=FALSE) 
plot(log(r.s[[2]]) , 
     col=grayscale_colors, 
     axes=FALSE) 

# Load raster to crop to
s2.root<-"/Users/jm622/Sentinel/Sentinel-2/Outputs/"
r2.s<-stack(paste(s2.root,"wadebridge_10m_WGS84_S2A_MSIL2A_20170617_T30UUB.tif",sep=""))

# CROP S1 raster and calculate logs
wdbg_s1<-crop(r.s,r2.s)
# log_wdbg_s1<-log(wdbg_s1)

# WriteRaster 
dir.out<-s1.root
fileout<-paste(dir.out,"S1_April_July_Stack4View.tif",sep="")
writeRaster(wdbg_s1,file=fileout,overwrite=TRUE)

############################################

# DISPLAY S! RGBs using saved logged S1 bands
s1rgb.s<-stack(paste(s1.root,"S1_April_July_Stack4View.tif"))

mapview(s1rgb.s[[1]])
mapview(s1rgb.s[[1]],
        col.regions=grayscale_colors, 
       # quantiles = c(0.02, 0.98),
        maxpixels=1863165,
        legend=TRUE,na.color="transparent")


############
# View RGBs 
# Requires adapting raster size limit
# RGB FUNCTION
RGB_colors<-function(r.s, r,g,b,quantiles){
  mat<-cbind(getValues(raster(r.s,layer=r)),
             getValues(raster(r.s,layer=g)),
             getValues(raster(r.s,layer=b))
  )
  
  for(i in seq(ncol(mat))){
    z <- mat[, i]
    lwr <- stats::quantile(z, quantiles[1], na.rm = TRUE)
    upr <- stats::quantile(z, quantiles[2], na.rm = TRUE)
    z <- (z - lwr) / (upr - lwr)
    z[z < 0] <- 0
    z[z > 1] <- 1
    mat[, i] <- z
  }
  
  na_indx <- apply(mat, 1, anyNA)
  cols <- mat[, 1]
  cols[na_indx] <- "transparent"
  cols[!na_indx] <- grDevices::rgb(mat[!na_indx, ], alpha = 1)
  p <- function(x) cols
  return(p)
} # end function
##############################

# RGB 1 - april (VV,VH,VV/VH)
red<-2; green<-1; blue<-5
rgbpalette<-RGB_colors(s1rgb.s, red,green,blue,c(0.02,0.98))


map<-leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11) 
map %>%
  addProviderTiles("Esri.WorldImagery")  %>%  
  addScaleBar() %>% 
  clearControls() %>%
  clearImages()  %>%
  addRasterImage(x=s1rgb.s[[red]],colors=rgbpalette,
                 opacity=1,
                 maxBytes=5000000,
                 project=FALSE) # NOTE requires same band number as red call to rgbpalette

# RGB 1 - july (VV,VH,VV/VH)
red<-4; green<-3; blue<-6
rgbpalette<-RGB_colors(s1rgb.s, red,green,blue,c(0.02,0.98))


map<-leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11) 
map %>%
  addProviderTiles("Esri.WorldImagery")  %>%  
  addScaleBar() %>% 
  clearControls() %>%
  clearImages()  %>%
  addRasterImage(x=s1rgb.s[[red]],colors=rgbpalette,
                 opacity=1,
                 maxBytes=5500000,
                 project=FALSE) # NOTE requires same band number as red call to rgbpalette

########

# RGB 3 - classify across time (VV/VH(t2), VH(t1),VV(t1)) - own invention check logic
red<-4; green<-2; blue<-1
rgbpalette<-RGB_colors(s1rgb.s, red,green,blue,c(0.02,0.98))

map<-leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11) 
map %>%
  addProviderTiles("Esri.WorldImagery")  %>%  
  addScaleBar() %>% 
  clearControls() %>%
  clearImages()  %>%
  addRasterImage(x=s1rgb.s[[red]],colors=rgbpalette,
                 opacity=1,
                 maxBytes=5000000,
                 project=FALSE) # NOTE requires same band number as red call to rgbpalette


# RGB 4 - change monitoring using VV-VHt1,VV-VHt2, VV-VHt2-VV-VHt1
red<-5; green<-6; blue<-7
rgbpalette<-RGB_colors(s1rgb.s, red,green,blue,c(0.02,0.98))


map<-leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11) 
map %>%
  addProviderTiles("Esri.WorldImagery")  %>%  
  addScaleBar() %>% 
  clearControls() %>%
  clearImages()  %>%
  addRasterImage(x=s1rgb.s[[red]],colors=rgbpalette,
                 opacity=1,
                 maxBytes=5500000,
                 project=FALSE) # NOTE requires same band number as red call to rgbpalette

# RGB 5 - change monitoring using VHt1,VHt2, VHt2-VHt1 - very different color to SNAP v 
# Distinguishes between bleaf and conifer? Or is it valley vs flat
red<-1; green<-3; blue<-8
rgbpalette<-RGB_colors(s1rgb.s, red,green,blue,c(0.02,0.98))


map<-leaflet() %>% 
  setView(lng = -4.8, lat = 50.5, zoom = 11) 
map %>%
  addProviderTiles("Esri.WorldImagery")  %>%  
  addScaleBar() %>% 
  clearControls() %>%
  clearImages()  %>%
  addRasterImage(x=s1rgb.s[[red]],colors=rgbpalette,
                 opacity=1,
                 maxBytes=5500000,
                 project=FALSE) # NOTE requires same band number as red call to rgbpalette


es same band number as red call to rgbpalette
#####################################################
# TRY resampling - see effect


