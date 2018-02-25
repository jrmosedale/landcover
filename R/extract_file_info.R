# Get information from Sentinel files in several directories
# Queries all files in sentinel directories
######################
# Functions for calculate julian dates - uses insol package
JDdmy<-function(day,month,year) {
  require(insol)
  options(digits=12)
  jdate<-insol::JD(ISOdate(year,month,day))
  return(jdate)
}
DMYjd<-function(jd) {
  require(insol)
  options(digits=12)
  newdate<-as.POSIXlt(insol::JD(jd,inverse=TRUE))
  dmy<-data.frame(day=newdate$mday,month=newdate$mon+1,year=newdate$year+1900)
  return (dmy)
}

# Returns list of unique files meeting criteria - irrespective of file type
# Criteria: product type, start and end dates as julian dates
# If product=="" then returns all product types
getfiles<-function(filelist.df,product,tile,start.date,end.date){
  if(product=="") res.df<-filelist.df[which(filelist.df$jdate>=start.date & filelist.df$jdate<=end.date),]
  if(product!="") res.df<-filelist.df[which(filelist.df$prod_type==product & filelist.df$jdate>=start.date & filelist.df$jdate<=end.date),]
  print(paste("Returning",nrow(res.df)," files"))
  return(res.df)
}

#####################
library(insol)

dirs<-c(  "/Volumes/Sentinel_Store/Sentinel/Sentinel_2/1C_Products",
             "/Volumes/Sentinel_Store/Sentinel/Sentinel_2/1C_Products_zip",
             "/Volumes/Sentinel_Store/Sentinel/Sentinel_2/2A_Products",
             "/Volumes/Sentinel_Store/Sentinel/Sentinel_2/2A_Products_zip" )

dirs<-c(  "/Users/jm622/Sentinel/Sentinel-2/Level_2A",
          "/Users/jm622/Sentinel/Sentinel-2/Level_2A_zip")



for (n in 1:length(dirs)){
  dir_in<-dirs[n]
  print(dir_in)
  #list.files(dir_in)
  filelist<-list.files(dir_in)
  satellite<-substr(filelist,1,3)
  s_type<-substr(filelist,5,8)
  prod_type<-substr(filelist,9,10)
  year<-substr(filelist,12,15)
  month<-substr(filelist,16,17)
  day<-substr(filelist,18,19)
  zone<-substr(filelist,40,41)
  tile<-substr(filelist,42,44)
  filetype<-substr(filelist,62,nchar(filelist))

  files.df<-data.frame(rep(dir_in,length(filelist)),satellite, s_type, prod_type, zone, tile, day,month,year,filetype)

  if(n==1) filelist.df<-files.df else filelist.df<-rbind(filelist.df,files.df)

  print(files.df)
}
print(filelist.df)

######################
# List types of file and location by date and tile

######################
# List all tiles in area of interest
tilelist<-c("29UPR","29UQR","29UQS","30UUA","30UUB","30UVA","30UVB")

# Calculate  dates for each file
filelist.df$dates<-paste(filelist.df$day,filelist.df$month,filelist.df$year,sep="/")
filelist.df$jdates<-JDdmy(filelist.df$day,filelist.df$month,filelist.df$year)

#######################
# Select by product and date
#######################
# Set parameters
product<-""
tile<-"UQS"
start.date<-JDdmy(1,9,2017)
end.date<-JDdmy(30,11,2017)
for (tile in c("UQS","UQR","UPR","UUA","UUB","UVA","UVB") ){
  # Get files meeting criteria and order by date
  valid.files<-getfiles(filelist.df,product,start.date,end.date)
  valid.files<-valid.files[valid.files$tile==tile,]
  valid.files<- valid.files[order(valid.files$jdates),]
  #print(valid.files)
  # Number of files taken on same day (identical)
  print(paste(tile,length(unique(valid.files$jdates))))
}

product<-""
start.dates<-c(JDdmy(1,3,2017),JDdmy(1,6,2017),JDdmy(1,9,2017),JDdmy(1,11,2017))
end.dates<-c(JDdmy(31,5,2017),JDdmy(31,8,2017),JDdmy(30,11,2017),JDdmy(31,12,2017))
for (d in 1:length(start.dates)){
  start.date<-start.dates[d];
  end.date<-end.dates[d]
  print(paste(start.date,end.date))
  for (tile in c("UQS","UQR","UPR","UUA","UUB","UVA","UVB") ){
    # Get files meeting criteria and order by date
    valid.files<-getfiles(filelist.df,product,start.date,end.date)
    valid.files<-valid.files[valid.files$tile==tile,]
    #valid.files<- valid.files[order(valid.files$jdates),]
    #print(valid.files)
    # Number of files taken on same day (identical)
    print(paste("Quarter",d,"Tile",tile,"Number:",length(unique(valid.files$jdates))))
  }
}
#######################
# Create table of file type by date
#######################
res<-table(valid.files$jdates,valid.files$prod_type)
rownames(res)<-unique(valid.files$dates)
print(res)

# as above by tile
res<-table(valid.files$jdates,valid.files$tile,valid.files$prod_type)
rownames(res)<-unique(valid.files$dates)
print(res)


# Remove duplicate files irrespective of directory






DMYjd<-function(jd) # correct
{
  options(digits=12)
  newdate<-as.POSIXlt(insol::JD(jd,inverse=TRUE))
  dmy<-data.frame(day=newdate$mday,month=newdate$mon+1,year=newdate$year+1900)
  return (dmy)
}

JDdoy<-function(doy,year)
{
  options(digits=12)
  newdate<-insol::doyday(year,doy)
  jdate<-insol::JD(ISOdate(newdate$year+1900,newdate$mon+1,newdate$mday))
  return(jdate)
}
