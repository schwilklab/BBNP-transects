# Code by Elizabeth Waring
# Code for BBNP Drought project with Dylan Scwhilk
# data collected in 2010 and 2011 at Big Bend National Park
# This code was used for data shaping.

library(plyr)

# All needed csv files

species <- read.csv("../data/species.csv",
                    strip.white=TRUE, stringsAsFactors = FALSE)
trans.2011 <- read.csv("../data/Trans.2011.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)
trans.2010 <- read.csv("../data/Trans.2010.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)
traits <-  read.csv("../data/traits.csv",strip.white=TRUE, stringsAsFactors = FALSE)


############################################################################
### STEP 1: Clean up data sets and organize them so they can be properly 
###          merged together.  Also add and calulate data like dieback


# Clean up species (5 column removed)
species2 <- species # for table 3
species <- subset(species, select = c(species,gf,longcode, spcode))


# Add in year codes
trans.2011$year <- 2011
trans.2010$year <- 2010
trans.2011$notes <- NULL
trans.2011$transect<- NULL
# rename colum in 2010 as coding for species is different between years
names(trans.2010)  [4] <- "longcode"

# Dist is already calculated in the 2010 data, so it must be added to 2011
trans.2011$dist <- trans.2011$stop - trans.2011$start
trans.2010$dieback <- 0 #no dieback measured in 2010
names(trans.2010) [2] <- "ttrans" #renamed so column names match pre-merge


# change data from site names to elevations at which data were collected
trans.2010$site <- factor(trans.2010$site, levels = c("C3","C2","C1","BR1","PT1","PT2"))
names(trans.2010)[1] <- "elev"
levels(trans.2010$elev) <- c("666", "871", "1132", "1411", "1690", "1920")

trans.2011$site <- factor(trans.2011$site, levels = c("C3","C2","C1","BR","PT1","PT2") )
names(trans.2011)[1] <- "elev"
levels(trans.2011$elev) <- c("666", "871", "1132", "1411", "1690", "1920")

# get the two species code forms alone.
speccode <- subset(species, select=c(longcode, spcode))


# Combine 2010 to get same spcodes as 2011

trans.2010 <- merge(speccode,trans.2010, by = "longcode", all.y = TRUE)
trans.2010$longcode =NULL

# Reorder columns
trans.2010 <- trans.2010[c(1,3,2,9,4,5,8,7,6)]
# Combine the data from 2010 to 2011
trans.all <- rbind(trans.2010, trans.2011)


# do dieback calculations
trans.all$dieback[is.na(trans.all$dieback)] <- 0
trans.all$dieback <-  trans.all$dieback / 100
trans.all$deaddist <- trans.all$dist * trans.all$dieback

# Elevation as a continuous varible
trans.all$elev <- as.numeric(as.character(trans.all$elev))
trans.all$year <- factor(trans.all$year)

# Make a factor variable for elevation as well
trans.all$felev <- trans.all$elev
trans.all$felev <- as.factor(trans.all$felev)
levels(trans.all$felev) <-c("666 m","871 m","1132 m","1411 m","1690 m",
                            "1920 m") 

############################################################################
### STEP 2: Calculate cover and rlative cover for each species, then produce
###          some subsets so we can do analyses by different groups. We'll
###          calculate total cover by each group so we can relativize by
###          different categories

## as a check of replication
## calculate number of transects per site
ddply(trans.all, .(elev, year), summarize, ntrans = length(unique(ttrans)))

# subset that excludes HERB (just our species of interest)
trans.plants <- subset(trans.all,trans.all$spcode!="HERB" & 
                         trans.all$spcode!="BG")
## put growth form in there
# Made two versions of the vectors to test affects on all woody plants
# and affects on different growth forms.  vectors ending in 2 are for 
# for growth form analysis.

trans.plants2 <- merge(trans.plants, species, all=TRUE)

# now lets just get a summary by transect of total cover and total dieback
plants.tcover <-  ddply(trans.plants, .(elev, felev, ttrans, year),
                        summarise,
                        tcover = sum(dist)/50, 
                        tdieback =  sum(deaddist)/50)
plants.tcover2 <-  ddply(trans.plants2, .(elev, felev, ttrans, year, gf),
                         summarise,
                         tcover = sum(dist)/50, 
                         tdieback =  sum(deaddist)/50)
plants.tcover2<-na.omit(plants.tcover2)

# summary of LIVING plant cover by transects and elevations
# Also proprotional dieback
plants.lcover <-ddply(plants.tcover, .(elev,felev, ttrans, year),
                      summarise,
                      lcover= sum(tcover-tdieback),
                      pdieback = sum(tdieback/tcover))

plants.lcover2 <-ddply(plants.tcover2, .(elev,felev, ttrans, year, gf),
                       summarise,
                       lcover= sum(tcover-tdieback),
                       pdieback = sum(tdieback/tcover))


# merge living and total cover
plants.tcover <- merge(plants.tcover, plants.lcover)
plants.tcover2 <- merge(plants.tcover2, plants.lcover2)

# now let's calculate cover and dieback for each species for each transect
plants.cover <- ddply(trans.plants, .(elev, felev, ttrans,year,spcode),
                      summarise,
                      cover = sum(dist)/50, 
                      dieback = sum(dist*dieback))

plants.cover2 <- ddply(trans.plants2, .(elev, felev, ttrans,year,spcode, gf),
                       summarise,
                       cover = sum(dist)/50, 
                       dieback = sum(dist*dieback))

# Get relative cover for each species by transect by merging total cover by
# transect with cover by species
plants.cover <- merge(plants.cover, plants.tcover)
plants.cover$relcover <- plants.cover$cover / plants.cover$tcover
plants.cover <- merge(plants.cover, species, all=TRUE)

plants.cover2 <- merge(plants.cover2, plants.tcover2)

# Remove unknowns and vine
# believe only unknow is "hailob" as well as some spcode with no info:
# BG, HERB, OPIMB, redlea, roubro, unkjoi, YUELA, ZIOBT

plants.cover<- na.omit(plants.cover)
plants.cover <- subset(plants.cover, gf=="shrub" | gf=="subshrub" | gf=="succulent" | gf=="tree")

plants.cover2<- na.omit(plants.cover2)
plants.cover2 <- subset(plants.cover2, gf=="shrub" | gf=="subshrub" | gf=="succulent" | gf=="tree")


# For some reason the year keeps reverting back to a double from a integer
plants.cover$year <- factor(plants.cover$year)

# logit transformation for relative cover
epsilon <- 0.0001
plants.cover$logPrelcover <- log((abs(plants.cover$relcover - epsilon))/
                                   (1-(abs(plants.cover$relcover - epsilon))))


# relative cover per transect
plants.relcover <- ddply(plants.cover, .(elev, felev, ttrans, year, gf),
                         summarise,
                         logPrelcover=sum(logPrelcover),
                         relcover=sum(relcover))


# dieback only occured in 2011, subset for analysis, could probably do this
# with just the tran.2011 data


dieback.2011 <- subset(plants.cover, plants.cover$year=="2011")
dieback2.2011 <-subset(plants.cover2, plants.cover2$year=="2011")

# There are plants with 100% dieback so epsilon must be subtracted for logit
epsilon <- 0.0001
dieback2.2011$logPdieback <- log((abs(dieback2.2011$pdieback - epsilon))/
                                   (1-(abs(dieback2.2011$pdieback - epsilon))))

totalDieback <- ddply(dieback2.2011, .(elev, felev, ttrans),
                      summarise, dieback=mean(dieback),
                      tdieback=mean(tdieback),
                      pdieback=mean(pdieback),
                      logPdieback=mean(logPdieback))
dieback.2011 <- ddply(dieback2.2011, .(elev, felev, ttrans, gf),
                      summarise, dieback=mean(dieback), 
                      tdieback=mean(tdieback),
                      pdieback=mean(pdieback),
                      logPdieback=mean(logPdieback)
)
# for dieback and leaf trait analysis
dieback.traits <-ddply(plants.cover2, .(elev, felev, ttrans, year, spcode, gf),
                       summarise,tdieback=sum(tdieback),
                       lcover=sum(lcover + 0.00001),
                       pdieback=mean(pdieback),
                       cover=mean(cover))

dieback.traits <-subset(dieback.traits, dieback.traits$year=="2011")