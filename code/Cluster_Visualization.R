#GOAL: visualization of the cluster data

# helpful post: http://www.sthda.com/english/wiki/beautiful-dendrogram-visualizations-in-r-5-must-known-methods-unsupervised-machine-learning 


# Set Up ------------------------------------------------------------------

# Libraries
  library(ape)
  library(lubridate)
  library(geojsonsf)
  library(sf)
  library(RColorBrewer)
  library(dendextend)
  library(pvclust)
  library(dynamicTreeCut)
  library(RColorBrewer)

# Read the data
setwd("D:/Data_AVA_Clusters")
data.df<-readRDS("cluster_data.rds")
z.scores<-readRDS("z_scores.rds")
clusters<-readRDS("clusters.rds")

# AVA polygons
data.url<-"https://raw.githubusercontent.com/UCDavisLibrary/ava/master/avas_aggregated_files/avas.geojson"
avas<-geojson_sf(data.url)
#avas<-st_transform(avas, 2163) #2063=Albers North American Equal Area Conic

#remove ulupalakua because it's in Hawaii and prism doesn't have that in the regular dataset
avas<-avas[-(which(avas$ava_id=="ulupalakua")), ]



# Analysis ----------------------------------------------------------------
#plot(clusters, hang=-1, cex=0.6)


clusters.dendrogram<-as.dendrogram(clusters)

# plot(clusters.dendrogram, 
#      type="rectangle", 
#      ylab="height", 
#      horiz = FALSE, 
#      #cex = 0.1,
#      leaflab = "none"
#      #mar=c(5,3,3,3),
#      #h=10.1
#      )
# 
# 
# #Draw a line on the Dendrogram
# #     https://stackoverflow.com/questions/49091292/how-to-line-cut-a-dendrogram-at-the-best-k
# k <- 6
# n <- nrow(avas)
# MidPoint <- (clusters$height[n-k] + clusters$height[n-k+1]) / 2 #calculate the midpoint of the branches that makes k clusters
# abline(h = MidPoint, lty=2)



#plot(as.phylo(clusters), cex=0.2, label.offset = 0.3)
#plot(as.phylo(clusters), type = "fan")

n.groups<-6 #how many clusters to make
#h.cut<-10.1 #where to cut the tree

groups<- cutree(clusters, 
                k=n.groups #cut the tree into n.groups
                #h=h.cut
)


# ACTUAL FIGURE: using the dendextend package
#     dendextend: https://cran.r-project.org/web/packages/dendextend/vignettes/dendextend.html 
#     Color Palette help: https://github.com/EmilHvitfeldt/r-color-palettes

#clusters$labels<-c()
clusters.dendrogram<-as.dendrogram(clusters)
no.groups<-6

group.colors<-c("#bf2110", "#f48843", "#FEE08B", 
                #"#ABDDA4", 
                "#548b49", "#3288BD", "#5E4FA2")
#group.colors<-rainbow(no.groups)

par(mar=c( 2, 0, 0, 25), cex=0.3)

clusters.dendrogram %>% 
  set("branches_k_color", value=group.colors, k = no.groups) %>%
  plot(cex=0.05, horiz=T,
       ylab="Difference") #, leaflab = "none") 

par(mar=c(0,0,0,0))
  
clusters.dendrogram %>% 
  rect.dendrogram( 
                k=no.groups, 
                horiz=T,
                #cluster = groups,
                #text = c(6,7,2,1,5,4,3),
                xpd = FALSE,
                border = 8, 
                lty = 2, 
                lwd = 1
                )

colors.plot.order=c("#548b49", "#bf2110","#5E4FA2","#f48843","#3288BD","#FEE08B")

colored_bars(colors=colors.plot.order[cutree(clusters.dendrogram, k=6)], dend=clusters.dendrogram, horiz = T)


#viz dynamiccutree

    # How many clusters?
# n.clusters<-dynamicTreeCut::cutreeDynamic(
#   dendro=clusters, 
#   minClusterSize = 15, #20
#   distM = as.matrix(dist(z.scores)),
#   method = "hybrid",
#   verbose = TRUE)
# 
# n.clusters<-dynamicTreeCut::cutreeDynamic(
#   dendro=clusters, 
#   minClusterSize = 15, #20
#   distM = as.matrix(dist(z.scores)),
#   method = "tree",
#   verbose = 4)
# 
# n.clusters.ordered<-n.clusters[order.dendrogram(clusters.dendrogram)]
# ngroups<- unique(n.clusters) - (0 %in% n.clusters)
# ngroups<-length(ngroups)
# groupcolors<-rainbow(ngroups)
# groupcolors<-c("#bf2110", "#f48843", "#FEE08B", 
#                  #"#ABDDA4", 
#                  "#548b49", "#3288BD") #, "#5E4FA2")
# 
# par(cex=.5, mar=c(2, 1, 0, 20))
# #par(cex=.5, mar=c(20,2, 1, 0))
# clusters.dendrogram %>% 
#   set("labels_cex", value=.6) %>% 
#   branches_attr_by_clusters(n.clusters.ordered, values  = groupcolors) %>% 
#   plot(horiz=T)
# 
# colored_bars(colors=groupcolors[n.clusters], dend=clusters.dendrogram, horiz = T)
# 
# #maps
# 
# grouped.avas<-cbind(avas, groups) 
# #cutree.avas<-cbind(avas, groups, n.clusters)
# names(cutree.avas)[23]<-"cutree_groups"
# 
# #group.colors<-c("darkred", "darkorange", "gold", "darkolivegreen3", "navyblue")[grouped.avas$groups]
# group.colors<-brewer.pal(n=ngroups, name="Set1")[cutree.avas$cutree_groups]
# avas.bbox<-st_bbox(avas)
# plot(states$geometry, xlim=avas.bbox[c(1,3)], ylim=avas.bbox[c(2,4)], border="gray")
# plot(cutree.avas["groups"], col=group.colors, border="gray", add=TRUE)
# 
# st_write(obj=grouped.avas, "avas_cutree_2022-05-25-1235.shp", append = FALSE)

#heatmap
#heatmap(as.matrix(z.scores), RowSideColors=groupcolors[n.clusters])

#how do we get this dendrogram to be the same as the other one?
#par(mar=c(20, 3, 3, 2), cex=0.5)

winecolors<-colorRampPalette(c("white", "#520E1F"))


heatmap(
  as.matrix(z.scores), 
  Rowv = clusters.dendrogram,
  margins = c(10,1),
  col=winecolors(10), #brewer.pal(9, "Greys"),
  labRow = c(""),
  labCol = c("Precipitation (range)", "Precipitation (mean)", "Elevation (range)", "Elevation (mean)", "Temperature (range)", "Temperature (mean)", "Clay 0-5cm (mean)", "Clay 15-30cm (mean)", "Clay 5-15cm (mean)", "Sand 0-5cm (mean)", "Sand 15-30cm (mean)", "Sand 5-15cm (mean)", "Silt 0-5cm (mean)", "Silt 15-30cm (mean)", "Silt 5-15cm (mean)", "Clay 0-5cm (range)", "Clay 15-30cm (range)", "Clay 5-15cm (range)", "Sand 0-5cm (range)", "Sand 15-30cm (range)", "Sand 5-15cm (range)", "Silt 0-5cm (range)", "Silt 15-30cm (range)", "Silt 5-15cm (range)"),
  RowSideColors=colors.plot.order[cutree(clusters.dendrogram, k=6)])

legend(x="topleft", legend=c("low", "medium", "high"), fill=winecolors(3), cex=0.5)
