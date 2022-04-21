# Classifying American Viticultural Areas Based on Environmental Data

This repository contains code related to Michele Tobias' 2022 [FOSS4G Academic Track](https://2022.foss4g.org/cfp-academic_track.php) paper submission "Classifying American Viticultural Areas Based on Environmental Data".

Using the UC Davis AVA dataset alongside datasets defining environmental characteristics such as soils, climate, and elevation, we seek to understand how the characteristics present within the AVA boundaries are similar to each other using a hierarchical clustering process.  

![Alt text](images/cluster_example_2022-04-20.jpg "An example of results of a cluster analysis of AVA boundaries using climate variables")

[ISPRS Publisher Guidelines](https://www.isprs.org/documents/orangebook/app5.aspx )

**Submission Deadline:** June 1, 2022

## Data Sources

UC Davis' [AVA Digitizing Project](https://github.com/UCDavisLibrary/ava)

 * **Current AVA boundaries:** avas.geojson

Oregon State University's [PRISM Climate Data](https://prism.oregonstate.edu/)

 * **Precipitation 30 Year Climate Normals:** PRISM_ppt_30yr_normal_800mM3_annual_bil.bil
 * **Mean Temperature 30 Year Climate Normals:** PRISM_tmean_30yr_normal_800mM3_annual_bil.bil
 * **Minimum Temperature 30 Year Climate Normals:** PRISM_tmin_30yr_normal_800mM3_annual_bil.bil
 * **Maximum Temperature 30 Year Climate Normals:** PRISM_tmax_30yr_normal_800mM3_annual_bil.bil
 * **Elevation:** PRISM_us_dem_800m_bil.bil
 
## Workflow

1. For each AVA boundary and each raster dataset:
	1. Extract the cells that intersect the boundary.
	1. Summarize the extracted data with the mean and range (lowest value subtracted from the highest value)
1. For each attribute (column), calculate the z-score for each record: z=(value-mean)/sd
1. Calculate a dissimilarity matrix
1. Hierarchical clusters

## Outstanding Questions

1. Can I incorporate categorical data such as soil series name from SSURGO into this analysis? Or does hierarchical clustering require only numerical data?
1. The samples here are not geographically distinct - there is overlap among boundaries. Do I need to worry about lack of independence? Spatial autocorrelation?
1. What other datasets would be interesting/useful to include?

## Document Manifest
*code* folder
  - `AVA_Clustering.R` - main analysis code for this paper

`LICENSE` - license for the code

`README.md` - the main informational file for the repository

## License
This repository is [licensed](LICENSE) under the Apache 2.0 License.


