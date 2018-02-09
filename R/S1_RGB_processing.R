library(raster)

dir_r<-"/Users/jonathanmosedale/Documents/Exeter/Sentinel/Sentinel-1/batch_outputs/tif_output/"
r<-raster(paste(dir_r,"ncornwall_0_of_S1A_IW_GRDH_1SDV_20170404T181342_20170404T181407_015998_01A638_A9EB_RGB.tif",sep=""))
r2<-raster(paste(dir_r,"subset_0_of_S1A_IW_GRDH_1SDV_20170728T180533_20170728T180558_017675_01D975_1774_RGB.tif",sep=""))
plot(r)
plot(r2)
