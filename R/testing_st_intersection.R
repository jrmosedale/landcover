pol = st_polygon(list(rbind(c(0,0), c(1,0), c(1,1), c(0,1), c(0,0))))
b = st_sfc(pol, pol + c(.8, .2))
c<-st_sfc(pol + c(.2, .8))
d<-st_sfc(pol + c(.2, .8),pol + c(.4, .4))
e<-st_sfc(pol + c(-.5, -0.8))

par(ar = rep(0, 2))
plot(b, col = NA)
plot(d, add=TRUE,col="red")
plot(c,add=TRUE,col="blue")
plot(e,add=TRUE,col="yellow")
z<-st_difference(b,c)
plot(z)

x<-st_difference(b,d)
plot(x)

x<-st_difference(b,st_union(d))
plot(x)

# Keep polygons based on overlap with others
plot(b)
plot(e,add=TRUE,col="red")
over<-b[which(st_overlaps(b,e)==1)]
plot(over,add=TRUE,col="green")

# Keep only intersected area - only works where e= single polygon
plot(b)
plot(e,add=TRUE,col="red")
over<-st_intersection(b[which(st_intersects(b,e)==1)],e)
plot(over,add=TRUE,col="green")

# Multiple polygons in both - PROBLEM
plot(d)
plot(b,add=TRUE,col="red")
over<-st_cast(st_union(st_intersection(b,d)))
plot(over,add=TRUE,col="green")
