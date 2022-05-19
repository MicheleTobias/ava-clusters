#GOAL: visualization of the cluster data

# helpful post: http://www.sthda.com/english/wiki/beautiful-dendrogram-visualizations-in-r-5-must-known-methods-unsupervised-machine-learning 


# Set Up ------------------------------------------------------------------

# Libraries
  library(ape)
  library(lubridate)
  library(geojsonsf)
  library(sf)
  library(RColorBrewer)

# Read the data
setwd("D:/Data_AVA_Clusters")
clusters<-readRDS("clusters.rds")

# AVA polygons
data.url<-"https://raw.githubusercontent.com/UCDavisLibrary/ava/master/avas_aggregated_files/avas.geojson"
avas<-geojson_sf(data.url)
#avas<-st_transform(avas, 2163) #2063=Albers North American Equal Area Conic

#remove ulupalakua because it's in Hawaii and prism doesn't have that in the regular dataset
avas<-avas[-(which(avas$ava_id=="ulupalakua")), ]

#calculate the area
avas.area<-st_area(avas$geometry)

#get the dates
avas.dates<-parse_date_time(avas$created, orders=c("%Y/%m/%d"))


# Analysis ----------------------------------------------------------------
plot(clusters, hang=-1, cex=0.6)


clusters.dendrogram<-as.dendrogram(clusters)

plot(clusters.dendrogram, 
     type="rectangle", 
     ylab="height", 
     horiz = FALSE, 
     cex = 0.1, 
     mar=c(5,3,3,3),
     #h=10.1
     )


plot(as.phylo(clusters), cex=0.2, label.offset = 0.3)

plot(as.phylo(clusters), type = "fan")

n.groups<-6 #how many clusters to make
h.cut<-10.1 #where to cut the tree

groups<- cutree(clusters, 
                #k=n.groups #cut the tree into n.groups
                h=h.cut
)

grouped.avas<-cbind(avas, groups) 

#maps
#group.colors<-c("darkred", "darkorange", "gold", "darkolivegreen3", "navyblue")[grouped.avas$groups]
group.colors<-brewer.pal(n=n.groups, name="Set1")[grouped.avas$groups]
avas.bbox<-st_bbox(avas)
plot(states$geometry, xlim=avas.bbox[c(1,3)], ylim=avas.bbox[c(2,4)], border="gray")
plot(grouped.avas["groups"], col=group.colors, border="gray", add=TRUE)

st_write(obj=grouped.avas, "avas_7_groups.shp", append = FALSE)
