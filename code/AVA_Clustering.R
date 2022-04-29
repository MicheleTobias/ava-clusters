#GOAL: explore the AVAs dataset


# Set Up ------------------------------------------------------------------

#libraries
library(sf)
library(geojsonsf)
library(lubridate)
#library(prism)     #for downloading PRISM data
library(terra)
library(RColorBrewer)
library(XPolaris)   #for downloading Polaris (interpolated SSURGO) data

#working directory
setwd("C:\\Users\\mmtobias\\Box\\Documents\\Publications\\AVA_Clusters\\data")


# Custom Functions --------------------------------------------------------

# FUNCTION: xlocations()
# INPUTS: 
#       grid = a polygon layer representing a 1 degree grid
#       polygon = another polygon layer (an AVA in this script)
# OUTPUTS: a table of points representing the centroids of the grid cells that intersect the polygon layer, set up to feed to ximages() for downloadin the Polaris images
xlocations <- function(grid, polygon){
  tiles<-poly.degree[which(lengths(st_intersects(x=grid, y=polygon))>0),]
  
  centroids<-st_centroid(tiles)
  centroids<-st_transform(centroids, crs=4326)
  
  #make up an ID... letters & numbers
  count.centroids<-dim(centroids)[1]
  ids<-paste0(letters[1:count.centroids], 1:count.centroids)
  
  locations.table<-cbind.data.frame(
    ids, 
    st_coordinates(centroids)[,2], #lat is in the 2 spot
    st_coordinates(centroids)[,1]) #long is in the first spot
  names(locations.table)<-c("ID", "lat", "long")
  
  return(locations.table)
}

# Read the Data -----------------------------------------------------------

#PRISM data
    #___ precipitation ___
    ppt<-rast(".//PRISM_ppt_30yr_normal_800mM3_annual_bil//PRISM_ppt_30yr_normal_800mM3_annual_bil.bil")
    ppt.2163<-project(ppt, "epsg:2163") #use same crs as avas
    
    #___ temperature ___
    tmean<-rast(".\\PRISM_tmean_30yr_normal_800mM3_annual_bil\\PRISM_tmean_30yr_normal_800mM3_annual_bil.bil")
    tmean.2163<-project(tmean, "epsg:2163")
    
    tmin<-rast(".//PRISM_tmin_30yr_normal_800mM3_annual_bil//PRISM_tmin_30yr_normal_800mM3_annual_bil.bil")
    tmin.2163<-project(tmin, "epsg:2163")
    
    tmax<-rast(".//PRISM_tmax_30yr_normal_800mM3_annual_bil//PRISM_tmax_30yr_normal_800mM3_annual_bil.bil")
    tmax.2163<-project(tmax, "epsg:2163")
    
    #___ elevation ___
    elev<-rast(".//PRISM_us_dem_800m_bil//PRISM_us_dem_800m_bil.bil")
    elev.2163<-project(elev, "epsg:2163") #use same crs as avas



#state outlines for viz
    states<-st_read("C:\\Users\\mmtobias\\Box\\D Drive\\GIS_Data\\NaturalEarth\\ne_10m_admin_1_states_provinces\\ne_10m_admin_1_states_provinces.shp")
    states<-st_transform(states, "epsg:2163")

#ava polygons
    data.url<-"https://raw.githubusercontent.com/UCDavisLibrary/ava/master/avas_aggregated_files/avas.geojson"
    avas<-geojson_sf(data.url)
    avas<-st_transform(avas, 2163) #2063=Albers North American Equal Area Conic
    
    #remove ulupalakua because it's in Hawaii and prism doesn't have that in the regular dataset
    avas<-avas[-(which(avas$ava_id=="ulupalakua")), ]
    
    #calculate the area
    avas.area<-st_area(avas$geometry)
    
    #get the dates
    avas.dates<-parse_date_time(avas$created, orders=c("%Y/%m/%d"))

#plot the dates over time
# plot(
#   x=avas.dates, 
#   y=(avas.area/1000000), 
#   xlab="Date", 
#   ylab=expression('Area - km'^'2'),
#   main="AVA Area"#,
#   #ylim=c(0, 15000)
#   )


# Climate -----------------------------------------------------------------

#___ precipitation ___
ppt.df<-data.frame()

for (i in 1:length(avas$ava_id)){
  #get the values from the raster
  extract<-terra::extract(x=ppt.2163, y=vect(avas$geometry[i]))
  extract.data<-na.omit(extract$PRISM_ppt_30yr_normal_800mM3_annual_bil)
  
  #summarize the data
  extract.min<-min(extract.data)
  extract.max<-max(extract.data)
  extract.range<-extract.max-extract.min
  extract.mean<-mean(extract.data)
  
  #assemble the data
  extract.i<-c(extract.range, extract.mean)
  ppt.df<-rbind(ppt.df, extract.i)
  names(ppt.df)<-c("ppt_range", "ppt_mean")
}

#___ temperature ___
tmean.df<-c()
tmax.df<-c()
tmin.df<-c()

for (i in 1:length(avas$ava_id)){
  #get the values from the raster
  
  #tmean
  extract<-terra::extract(x=tmean.2163, y=vect(avas$geometry[i]))
  extract.data<-na.omit(extract[,2])
  extract.mean<-mean(extract.data)
  tmean.df<-c(tmean.df, extract.mean)
  
  #tmax
  extract<-terra::extract(x=tmax.2163, y=vect(avas$geometry[i]))
  extract.data<-na.omit(extract[,2])
  extract.max<-mean(extract.data)
  tmax.df<-c(tmax.df, extract.max)  
  
  #tmin
  extract<-terra::extract(x=tmin.2163, y=vect(avas$geometry[i]))
  extract.data<-na.omit(extract[,2])
  extract.min<-mean(extract.data)
  tmin.df<-c(tmin.df, extract.min) 
  
}

trange.df<-tmax.df-tmin.df
t.df<-cbind.data.frame(trange.df, tmean.df)

names(t.df)<-c("t_range", "t_mean")


# Elevation ---------------------------------------------------------------

elev.df<-data.frame()

for (i in 1:length(avas$ava_id)){
  #get the values from the raster
  extract<-terra::extract(x=elev.2163, y=vect(avas$geometry[i]))
  extract.data<-na.omit(extract$PRISM_us_dem_800m_bil)
  
  #summarize the data
  extract.min<-min(extract.data)
  extract.max<-max(extract.data)
  extract.range<-extract.max-extract.min
  extract.mean<-mean(extract.data)
  
  #assemble the data
  extract.i<-c(extract.range, extract.mean)
  elev.df<-rbind(elev.df, extract.i)
  names(elev.df)<-c("elev_range", "elev_mean")
}



# Soils -------------------------------------------------------------------
    #SSURGO WMS: https://srfs.wr.usgs.gov/arcgis/rest/services/LTDL_Tool/GSSURGO_Data/MapServer 
    
    # soilDB package: http://ncss-tech.github.io/soilDB/
    
    # Soil Data Access Web Service Help 
    #  * https://sdmdataaccess.nrcs.usda.gov/ 
    #  * https://sdmdataaccess.nrcs.usda.gov/WebServiceHelp.aspx 
    
    # XPolaris package for working with POLARIS database (30m resolution) - Fills gaps in SSURGO - cc attribution-noncommercial - 
    #   * https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2018WR022797 
    #   * https://github.com/cran/XPolaris

# Create the Polaris 1 degree grid
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

    #turn the raster into polygons and set the CRS to match the AVAs
    poly.degree<-st_as_sf(as.polygons(rast.degree))
    poly.degree<-st_transform(poly.degree, crs=2163)

    
# For each AVA, set up the Polaris locations table
for (i in 1:nrow(avas)){
  print(avas$name[i])
  
}






# Build the Data Frame of Attributes --------------------------------------
cluster.data<-cbind.data.frame(avas$ava_id, 
                               #avas.area, #removed area because it seemed redundant with the ranges of ppt, elev, and temp
                               ppt.df, elev.df, t.df)
names(cluster.data)[1]<-"ava_id"

# Normalize the data by calculating the z score for each column = (x-mean)/sd
z.scores<-data.frame(
  matrix(
    ncol=dim(cluster.data)[2], 
    nrow=dim(cluster.data)[1]
  )
)
names(z.scores)<-names(cluster.data)
z.scores$ava_id<-cluster.data$ava_id

for (i in 2:length(names(cluster.data))){
  print(i)
  
  data<-cluster.data[,i]
  
  z<-(data-mean(data))/sd(data)
  
  z.scores[,i]<-z
}


# Cluster Analysis --------------------------------------------------------
#dissimilarity structure
#dissimilarity<-dist(cluster.data[, 2:ncol(cluster.data)])
dissimilarity<-dist(z.scores[, 2:ncol(z.scores)])

#hierarchical cluster analysis
clusters<-hclust(dissimilarity)
plot(clusters, cex=.5)

n.groups=6 #how many clusters to make
groups<- cutree(clusters, k=n.groups) #cut the tree into n.groups
grouped.avas<-cbind(avas, groups) 

#maps
#group.colors<-c("darkred", "darkorange", "gold", "darkolivegreen3", "navyblue")[grouped.avas$groups]
group.colors<-brewer.pal(n=n.groups, name="Set1")[grouped.avas$groups]
avas.bbox<-st_bbox(avas)
plot(states$geometry, xlim=avas.bbox[c(1,3)], ylim=avas.bbox[c(2,4)], border="gray")
plot(grouped.avas["groups"], col=group.colors, border="gray", add=TRUE)

st_write(obj=grouped.avas, "grouped_avas_no_area.shp", append = FALSE)