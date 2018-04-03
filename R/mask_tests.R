

in.root<-"/Volumes/Pocket_Sam/Data/"
root<-"/Volumes/Pocket_Sam/Data/MapApp/Indicator_data/"
dir_aoi<-"/Users/jonathanmosedale/Rprojects/landcover/masks/"

# Cornwall MHW with 500m buffer on land boundary
aoi<-st_read(paste0(dir_aoi,"cornwall_mainland_MHWpolygon_4326/cornwall_mainland_MHWpolygon_4326.shp"))

aoi_27700<-st_transform(aoi,27700)
st_write(aoi_27700,paste0(dir_aoi,"cornwall_mainland_MHWpolygon_27700.shp"))
