The metadata is in the format from metadata submitted to Ecological Archives (http://esapubs.org/archive/instruct_d.htm)<br>

<b>Title: Plant dieback under exceptional drought driven by elevation, not by plant traits, in Big Bend National Park, Texas USA</b><br>


<b>CLASS I. DATA SET DESCRIPTORS<br></b>
A. Data set identity:<br>
Title: Line-transect canopy cover and canopy dieback at various elevations at Big Bend National Park<br>
B. Data set identification code:<br>
Suggested Data Set Identity Code: BBNP201011<br>
C. Data set description<br>
Principal Investigator: Elizabeth F Waring Dylan W Schwilk<br>
Abstract: as above<br>
D. Key words: as above<br>
<b>CLASS II. RESEARCH ORIGIN DESCRIPTORS<br></b>
A. Overall project description<br>
Identity: Differences in canopy cover and composition at different elevations in Big Bend National Park<br>
Originator: Dylan W Schwilk<br>
Period of Study: October 2010 and 2011<br>
Objectives: To evaluate the impacts of drought on woody plant canopy cover<br>
Abstract: same as above.<br>
Sources of funding: Department of Biological Sciences, Texas Tech University<br>
B. Specific subproject description<br>
Study Site: Various sites with Big Bend National Park.  The lower elevational sites (666,841,1132 m) were located in the Chihuahuan Desert part of the park.  All three sites had a flat aspect with dominant growth form being desert and deciduous shrub species.  The site at 1411 m was an ecotone between the montane forests of the Chisos Mountains and the Chihuahuan Desert. This area had a northwest facing aspect with a mix of desert shrubs and trees. Lastly, the higher elevational sites (1690 and 1920 m) were a mixed Oak and Juniper forest.  These sites had North and Northwest facing aspects and were dominated by tree species.<br>
<br>
Research methods: The data were collected using line intercept transects (start, stop, dist in Trans.2011.csv & Trans.2011.csv).  Fifty-m transects were run in parallel with the slope at various elevations.  The canopy was measure as the points of intersection of the canopy with the line transect.  Individuals were identified to species when possible.  When individuals could not be identified to species due to lack of flowers or leaves, the growth form of the individual was noted for analysis by growth forms (see Species.csv for these data).<br>
Dieback was visually estimated in 2011 (dieback in Trans.2011.csv).  The dieback was the percent of the canopy that had died in 2011.  Death was confirmed by breaking twigs to check for live tissue. <br> 
Leaf traits were measured by collecting 2-5 leaves from 3-4 individuals of each species at each elevation in 2010.  The leaves were returned to Lubbock, TX on ice where leaf area was measured using a flat bed scanner (leafl in traits.csv). The leaf area was determined using Lamina (Bylesjö et al., 2008;doi:10.1186/1471-2229-8-82) The leaves were then dried in an oven at 80 ºC for 24 hours and weighed.  The leaf mass per area (LMA) was the grams of dried tissue over the leaf area (LMA in traits.csv).<br>

Project personnel: Dylan Schwilk, Elizabeth Waring, Brandon Pratt, students in the autumn 2010 and 2011 Ecological Strategies of Plants course<br>

<b>CLASS III. DATA STRUCTURAL DESCRIPTORS<br></b>
A. Data Set File<br>
Identity:<br>
Trans.2011.csv  – for line-intercept canopy and percent dieback data in 2011<br>
Trans.2010.csv  – for line-intercept canopy and percent dieback data in 2010<br>
Species_pub.csv  - for species names code in 2010 and 2011
Traits.csv – for leaf traits per species per elevation<br>
Size:<br>
Trans.2011-1583 lines, not including header row.<br>
Trans.2010-1985 lines, not including header row.<br>
Species.csv – 84 lines, not including header row.<br>
Traits.csv -- 46 lines, not including header row.<br>
Comments:<br>
Transects.csv –<br>
The number of transects per site was dependent on the density of the canopy cover.  Attempts were made to make the amount of cover measured at each site even.  Therefore the high elevation sites had few transects than the lower elevational sites.<br>
<br>

species.csv --<br>
Plants that we were able to id to growth form/family but were unable to id to species are listed in lowercase letters for their letter species code (both 5 and 6 letter long codes).  This was done for growth form analysis.  The species that were identified to species has their letter codes in uppercase (both 5 and 6 letter length).<br>

<br>

traits.csv –<br>
Leaf area was calculated using a LI-3100 leaf area meter (Li-Cor, Lincoln, NE).  Leaves were then dried and weighed to determining leaf weight for determining LMA.<br>
<br>
Format and storage mode: ASCII text, comma delimited. No compression schemes used.
Authentication procedures: For the Transects.csv data, the sum of start point values for the entire data set is 85165. The spcode is DAFOR for row 1000. For Species.csv, the spcode is MATRI for row 50. For traits.csv, the sum of all the LMA is 128.1353.  The spcode is JUDEP for row 25.<br>
B. Variable information<br>
See individual .csv files on data