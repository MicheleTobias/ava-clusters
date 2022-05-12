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

xlocations <- function(grid, polygon){
  tiles<-poly.degree[which(lengths(st_intersects(x=grid, y=polygon))>0),]
  
  centroids<-st_centroid(tiles)
  centroids<-st_transform(centroids, crs=4326)
  
  locations.table<-cbind.data.frame(
    letters[1:dim(centroids)[1]], #make up an ID... just a letter
    st_coordinates(centroids)[2], #lat is in the 2 spot
    st_coordinates(centroids)[1]) #long is in the first spot
  names(locations.table)<-c("ID", "lat", "long")
  
  return(locations.table)
}

xlocations(poly.degree, ava.test)




#checking that the results make sense visually
plot(tiles$geometry)
plot(poly.degree, border="gray", add=TRUE)
plot(tiles$geometry, add=TRUE, lwd=2)
plot(ava.test$geometry, add=TRUE, col="light green", border="dark green")
plot(centroids, add=TRUE, col="dark orange")

#download the data
df_images<-ximages(locations = locations.table,
        statistics = c('mean'),
        variables = c('sand','silt','clay'),
        layersdepths = c('0_5','5_15','15_30'))

xsoil(ximages_output = df_images)

test.raster<-rast(df_images$local_file[1])
ava.test.4326<-st_transform(ava.test, 4326)

plot(test.raster, main="Mean Sand, 0-5 cm")
plot(ava.test.4326$geometry, add=TRUE)



#----------------------------------------------------
library(gdalUtils)

avas<-avas[3:4,]
avas<-avas[4,]

image.points<-xlocations(grid, avas)

images<-ximages(image.points,
                statistics = c('mean'),
                variables = c('sand','silt','clay'),
                layersdepths = c('0_5','5_15','15_30'),
                localPath = "D:/Data_AVA_Clusters") #images were originally stored in C:\\Users\\mmtobias\\AppData\\Local\\Temp\\Rtmp6LliSp/POLARISOut/ 

# # put the images in a folder into a vrt
# clay.05.files<-as.list(list.files("D:/Data_AVA_Clusters/POLARISOut/mean/clay/0_5"))
# 
# setwd("D:/Data_AVA_Clusters/POLARISOut/mean/clay/0_5")
# 
# #make a vrt from the data in a folder
# gdalUtils::gdalbuildvrt(gdalfile=clay.05.files, output.vrt = "D:/Data_AVA_Clusters/vrt/clay_05.vrt", overwrite=TRUE)
# 
# #make a vrt from the data in a folder
# clay.05.rast<-rast("D:/Data_AVA_Clusters/vrt/clay_05.vrt")

avas4326<-st_transform(avas, 4326)

#function to make VRTs from the polaris data 
xvrt<-function(InputFolder, vrtPath){
  files.list<-as.list(list.files(InputFolder, full.names = TRUE))
  gdalUtils::gdalbuildvrt(gdalfile=files.list, output.vrt = vrtPath, overwrite=TRUE)
}

xvrt(InputFolder = "D:/Data_AVA_Clusters/POLARISOut/mean/sand/0_5", vrtPath = "D:/Data_AVA_Clusters/vrt/sand_05.vrt")
xvrt(InputFolder = "D:/Data_AVA_Clusters/POLARISOut/mean/clay/0_5", vrtPath = "D:/Data_AVA_Clusters/vrt/clay_05.vrt")

#automatially make the vrts from the directory
polaris.dir<-"D:/Data_AVA_Clusters/POLARISOut"

for (i in list.dirs(polaris.dir, full.names = TRUE, recursive=FALSE)){
  print(paste("current directory:", i))
  files<-list.files(i, full.names=TRUE)
  print(files)
  
  for (j in files){
    print(paste("current directory: ", j))
    data.folders<-list.files(j, full.names = TRUE)
    
    for (k in data.folders){
      print(paste("current directory: ", data.folders))
      #data.rasters<-list.files(k, full.names=TRUE)
      path.string<-strsplit(k, "/") #split the path up into component parts
      last.folder.pos<-length(path.string[[1]])
      save.vrt<-paste(path.string[[1]][(last.folder.pos-2):last.folder.pos], collapse="_")
      
      xvrt(
        InputFolder = k, 
        vrtPath = paste0("D:/Data_AVA_Clusters/vrt/", save.vrt, ".vrt"))
    }
  }
}

#make a stack of all the soil rasters
vrtpath<-"D:/Data_AVA_Clusters/vrt"
soilrasters<-rast(list.files(vrtpath, full.names = TRUE))

#sample the raster at each AVA
#   https://www.r-bloggers.com/2013/08/the-wonders-of-foreach/
#   https://privefl.github.io/blog/a-guide-to-parallelism-in-r/
#   LibLap has 8 cores (task manager -> Performance)

cl <- parallel::makeCluster(2)
doParallel::registerDoParallel(cl)

foreach(i=1:nrow(avas4326), .combine=c) %dopar% { #dopar for parallel; do for serial
  print(avas4326$name[i])
  #return(i)
}
  


#plot to see if it worked
terra::plot(clay.05.rast)
terra::plot(avas4326$geometry, add=T)

clay.05.crop<-terra::crop(clay.05.rast, avas4326)

clay.05.extract<-terra::extract(y=vect(avas4326), x=clay.05.crop)

#what if I masked the raster instead of clipping? would I even need to extract then? Nope! summary() gets what we need. Mask() seems to be a little quicker.
# this is helpful: https://rspatial.github.io/terra/reference/terra-package.html

clay.05.mask<-terra::mask(mask=vect(avas4326), x=clay.05.rast)
clay.05.values<-values(clay.05.mask)
clay.05.values<-summary(clay.05.mask)

#what if we add another layer? Can we add another variable and make a stack/brick/layer-cake/sandwich-cookie? Can we run sample() on that and get stats for each layer?
