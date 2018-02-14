# Calculate masks from OS boundary data
library(sf)

dir_OS<-"../../Data/OS/bdline_essh_gb/Data/GB/"
dir_out<-"masks/"
list.files(dir_OS)
list.files(dir_out)

# Function
# Inputs: 1. Core polygon to be buffered 2. Wider region (polygon or line) 3. buffer in same units as 1
# Output: buffered shape of same format (line/polygon as input 2)
create_buffer<-function(core_shape,wider_shape, buffer){
  if(st_crs(core_shape)!=st_crs(wider_shape)) warning("Inputs have different CRS")
  buffer_shape<-st_buffer(core_shape,buffer)
  # Clipping method depends on if wider shape = linestring or polygon(s)
  if ("LINESTRING" %in%  st_geometry_type(wider_shape)==FALSE) out_shape<-st_intersection(wider_shape, buffer_shape)
  #if ("LINESTRING" %in%  st_geometry_type(wider_shape)==TRUE){ # clip to bbox
  #  out_shape<-st_intersection(wider_shape, st_as_sfc(st_bbox(buffer_shape)) )
  #}
} # end create_buffer
# st_as_sfc(st_bbox(buffer_shape))


# Load OS data files for MHW and admin boundaries
GB_MHW<-st_read(paste0(dir_OS,"high_water_polyline.shp"))
SWcons<-st_read(paste0(dir_OS,"SW_constituencies.shp"))
class(SWcons) # "sf"         "data.frame"
plot(SWcons$geometry)
SWcons<-st_union(SWcons)
class(SWcons) # sfc multipolygon =   geometry set - no accompanying data
plot(SWcons)

# Load existing files created in qgis
Cornwall_IoS<-st_read(paste0(dir_OS,"Cornwall_and_IoS.shp"))
Cornwall<-Cornwall_IoS[Cornwall_IoS$NAME == "Cornwall",]
Cornwall_IoS<-st_union(Cornwall_IoS) # reduce to geometry  only
Cornwall<-st_union(Cornwall) # reduce to geometry  only
plot(Cornwall,add=TRUE,col="green")

# Set all crs to OS (assume already correctly transformed)
st_crs(Cornwall_IoS)<-st_crs(GB_MHW)
st_crs(Cornwall)<-st_crs(GB_MHW)
st_crs(SWcons)<-st_crs(GB_MHW)

# Create buffered admin regions from polygons
CornwallIoS.buf<-create_buffer(Cornwall_IoS,SWcons, 15000)
Cornwall.buf<-create_buffer(Cornwall,SWcons, 15000)
plot(CornwallIoS.buf)
plot(Cornwall.buf,add=TRUE,col="red")

# Convert to 4326 projecctions
# bbox for buffered Cornwall&IoS: xmin 67600 ymin -10000 xmax 262000 ymax 150000
cornwall_4326<-st_transform(Cornwall,4326)
cornwallbuf_4326<-st_transform(Cornwall.buf,4326)

# Write masks as shape files
st_write(cornwall_4326,dsn=paste(dir_out,"cornwall_mainland_adminpolygon_4326",sep=""),layer="cornwall_mainland_adminpolygon_4326",driver="ESRI Shapefile",delete_dsn=TRUE)
st_write(cornwallbuf_4326,dsn=paste(dir_out,"cornwall_mainland_adminpolygon_15kmbuf_4326",sep=""),layer="cornwall_mainland_adminpolygon_15kmbuf_4326",driver="ESRI Shapefile")


# MHW ISSUES
# Cornwall mainland MHW to buffered area using tailored bbox
# Define bbox
b.box<-st_bbox(Cornwall.buf) # or any polygon
b.box[1]<-67600
b.box[2]<- 10000
b.box[3]<- 262000
b.box[4]<- 150000 # raise ymax toen

# Clip MHW to enlarged area defined by b.box
Cornwall.MHW.buf<-st_intersection(GB_MHW, st_as_sfc(b.box) )
# Add vertical line at xmax
geom <- st_geometry(Cornwall.MHW.buf)
print(geom[[1]])
plot(Cornwall.MHW.buf$geometry)

res<-st_polygonize(Cornwall.MHW.buf)

Cornwall.MHW.buf<-st_union(Cornwall.MHW.buf)
Cornwall.MHW.buf<-create_buffer(Cornwall,GB_MHW, 15000)

# Cornwall and IoS
CornwallIoS.buf<-create_buffer(Cornwall_IoS,SWcons, 15000)
#CornwallIoS.buf<-st_union(CornwallIoS.buf)
plot(CornwallIoS.buf$geometry)

# Clip MHW to buffered area
CornwallIoS.MHW.buf<-create_buffer(Cornwall_IoS,GB_MHW, 15000)
plot(CornwallIoS.MHW.buf$geometry)

# CLosepolygon withvertical

# Convert to different projecctions
# OS proj
# bbox for buffered Cornwall&IoS: xmin 67600 ymin -10000 xmax 262000 ymax 150000
out_4326<-st_transform(out_shape,4326)
cornwall_4326<-st_transform(Cornwall,4326)
cornwallbuf_4326<-st_transform(Cornwall.buf,4326)

plot(cornwallbuf_4326$geometry)
plot()

st_write(cornwall_4326,dsn=paste(dir_out,"cornwall_mainland_adminpolygon_4326",sep=""),layer="cornwall_mainland_adminpolygon_4326",driver="ESRI Shapefile")
st_write(cornwallbuf_4326,dsn=paste(dir_out,"cornwall_mainland_adminpolygon_15kmbuf_4326",sep=""),layer="cornwall_mainland_adminpolygon_15kmbuf_4326",driver="ESRI Shapefile")

#out_4326<-st_transform(out_shape,4326)

out.crs<-
