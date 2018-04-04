pol = st_polygon(list(rbind(c(0,0), c(1,0), c(1,1), c(0,1), c(0,0))))
b = st_sfc(pol, pol + c(.8, .2))
c<-st_sfc(pol + c(.2, .8))
d<-st_sfc(pol + c(.2, .8),pol + c(.4, .4))

par(mar = rep(0, 2))
plot(b, col = NA)
plot(d, add=TRUE,col="red")

z<-st_difference(b,c)
plot(z)

x<-st_difference(b,d)
plot(x)

x<-st_difference(b,st_union(d))
plot(x)
