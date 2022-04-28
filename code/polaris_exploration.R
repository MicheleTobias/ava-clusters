#GOAL: figure out how to work with the xPolaris package to get soil data inside the AVA boundaries.


#devtools::install_github("lhmrosso/XPolaris")

library(XPolaris)
library(sf)
library(terra)

#create the list of tiles to download
# col names = "ID", "lat", "long" in decimal degrees
print(exkansas)

#look at the tiles you plan to download
xplot(locations = exkansas)

# aoi.vertexes<-rbind(c(-125,50),c(-65,50),c(-65,24),c(-125,24), c(-125,50))
# aoi.names<-c("nw", "ne", "sw", "se", "nw")
# aoi<-cbind.data.frame(aoi.names, aoi.vertexes[,1], aoi.vertexes[,2])
# names(aoi)<-c("ID", "lat", "long")
#aoi<-st_polygon(aoi.vertexes)

#create a 1 degree raster
xmax<- -65
xmin<- -125
ymax<- 50
ymin<-24
rast.degree<-rast(
  ncol=(xmax-xmin), 
  nrow=(ymax-ymin),
  xmin=xmin,
  xmax=xmax,
  ymin=ymin,
  ymax=ymax
  )

poly.degree<-st_as_sf(as.polygons(rast.degree))
poly.degree<-st_transform(poly.degree, crs=2163)

#test polygon
# coords<-list(matrix(c(40, -100, 35, -90, 42, -95, 40, -100), ncol=2, byrow=TRUE))
# poly.test<-st_polygon(coords)
# st_sfc(poly.test, crs=4326)
# st_crs(poly.test)<-4326

ava.test<-avas[which(avas$ava_id=="capay_valley"),]

tiles<-poly.degree[which(lengths(st_intersects(x=poly.degree, y=ava.test))>0),]

centroids<-st_centroid(tiles)

#checking that the results make sense visually
plot(tiles$geometry)
plot(poly.degree, border="gray", add=TRUE)
plot(tiles$geometry, add=TRUE, lwd=2)
plot(ava.test$geometry, add=TRUE, col="light green", border="dark green")
plot(centroids, add=TRUE, col="dark orange")

#download the data
ximages(locations = exkansas,
        statistics = c('mean'),
        variables = c('sand','silt','clay'),
        layersdepths = c('0_5','5_15','15_30'))
