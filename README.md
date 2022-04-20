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
 

## Document Manifest
*code* folder
  - `AVA_Clustering.R` - main analysis code for this paper

`LICENSE` - license for the code

`README.md` - the main informational file for the repository

## License
This repository is [licensed](LICENSE) under the Apache 2.0 License.


