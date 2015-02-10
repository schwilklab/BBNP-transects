# Code by Elizabeth Waring and Dylan Schwilk
# Code for BBNP Drought project with Dylan Scwhilk
# data collected in 2010 and 2011 at Big Bend National Park
# This code was used for data shaping.

library(plyr)

###############################################################################
## Step 1: Read in data, merge all years
###############################################################################
# All needed csv files
species <- read.csv("../data/species.csv",
                    strip.white=TRUE, stringsAsFactors = FALSE)
traits <-  read.csv("../data/traits.csv",strip.white=TRUE, stringsAsFactors = FALSE)


# transect data:
trans.2011 <- read.csv("../data/Trans.2011.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)
trans.2010 <- read.csv("../data/Trans.2010.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)
trans.2013 <- read.csv("../data/Trans.2013.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)

# Note, 2015 data is from Feb 2015!
trans.2015 <- read.csv("../data/Trans.2015.csv",strip.white=TRUE,
                       stringsAsFactors = FALSE)


# Add in year codes
trans.2011$year <- 2011
trans.2010$year <- 2010
trans.2013$year <- 2013
trans.2015$year <- 2015

# Clean up inconsistencies in data collection across years:
# rename colum in 2010 and 2013 as coding for species is different between years
names(trans.2010)[4] <- "longcode"
names(trans.2013)[4] <- "longcode"
names(trans.2015)[4] <- "longcode"
# and get short code for those years:
trans.2010 <- merge(trans.2010, species[4:5], all.x=TRUE)
trans.2013 <- merge(trans.2013, species[4:5], all.x=TRUE)
trans.2015 <- merge(trans.2015, species[4:5], all.x=TRUE)

cleanColumns <- function(x) {
    return( x[c("year", "site", "team", "transect", "spcode", "start", "stop",
                "dieback")])
}

trans.2010 <- cleanColumns(trans.2010)
trans.2011 <- cleanColumns(trans.2011)
trans.2013 <- cleanColumns(trans.2013)
trans.2015 <- cleanColumns(trans.2015)

# Now rbind the years and clean up workspace
trans.all <- rbind(trans.2010, trans.2011, trans.2013, trans.2015)
rm(trans.2010, trans.2011, trans.2013, trans.2015)


###############################################################################
## Step 2: Do data shaping and simple calculations
###############################################################################

# calculate distance
trans.all <- mutate(trans.all, dist = stop - start)

# change data from site names to elevations at which data were collected
trans.all$site <- factor(trans.all$site, levels = c("C3","C2","C1","BR1","PT1","PT2"))
trans.all$felev <-  trans.all$site
levels(trans.all$felev) <- c("666", "871", "1132", "1411", "1690", "1920")
# Elevation as a continuous varible
trans.all$elev <- as.numeric(as.character(trans.all$felev))

# Now make the factor version felev prettier:
levels(trans.all$felev) <-c("666 m","871 m","1132 m","1411 m","1690 m",
                            "1920 m")

# merge in growth form data
trans.all <- merge(trans.all, species[c("spcode", "species", "family", "gf")],
                   all.x=TRUE)

# do dieback calculations
# NA means zero in dieback:
trans.all$dieback[is.na(trans.all$dieback)] <- 0
trans.all$dieback <-  trans.all$dieback / 100
trans.all$deaddist <- trans.all$dist * trans.all$dieback

# year as factor
# trans.all$year <- factor(trans.all$year)


# unique transect ids
trans.all <- mutate(trans.all, transect = paste(year, team, transect, sep="."))


############################################################################
### STEP 3 : Calculate cover and relative cover for each species, then produce
###          some subsets so we can do analyses by different groups. We'll
###          calculate total cover by each group so we can relativize by
###          different categories

## as a check of replication
## calculate number of transects per site
ddply(trans.all, .(elev, year), summarize, ntrans = length(unique(transect)))

# subset that excludes HERB, BG (bare groud, and the one vine (just our species
# of interest)
trans.plants <- subset(trans.all,trans.all$spcode!="HERB" & 
                         trans.all$spcode!="BG" & gf != "vine")

### Total plant cover
# now lets just get a summary by transect of total cover and total dieback
plants.cover <-  ddply(trans.plants, .(year, elev, felev, transect),
                        summarise,
                        plants.cover = sum(dist)/50, 
                        plants.dieback =  sum(deaddist)/50)

plants.cover <- mutate(plants.cover, plants.lcover = plants.cover-plants.dieback,
                       plants.pdieback = plants.dieback/plants.cover)


#####################################################
## same thing by growth form

gf.cover <-  ddply(trans.plants, .(year, elev, felev, transect, gf),
                         summarise,
                         cover = sum(dist)/50, 
                         dieback =  sum(deaddist)/50)
gf.cover <- mutate(gf.cover, live.cover = cover - dieback, pdieback = dieback/cover)

gf.cover <- merge(gf.cover, plants.cover,
                  by = (c("year", "elev", "felev", "transect")))

# logit transformation for relative cover and dieback
epsilon <- 0.0001
gf.cover <- mutate(gf.cover, relcover = cover/plants.cover,
                   logitrelcover = log((abs(relcover - epsilon)) /
                                           (1-(abs(relcover - epsilon)))),
                   logitdieback = log((abs(pdieback - epsilon)) /
                                           (1-(abs(pdieback - epsilon))))
                   )


####################
## By species
####################


# now let's calculate cover and dieback for each species for each transect
species.cover <- ddply(trans.plants,
                       .(elev, felev, transect, year, spcode, family, species, gf),
                       summarise,
                       cover = sum(dist)/50, 
                       dieback = sum(dist*dieback),
                       live.cover = sum(cover-dieback),
                       pdieback = sum(deaddist) / sum(dist))

species.cover <- merge(species.cover, plants.cover,
                       by = (c("year", "elev", "felev", "transect")), all.x=TRUE)
species.cover <- mutate(species.cover, relcover = cover/plants.cover,
                        logitrelcover = log((abs(relcover - epsilon)) /
                                                (1-(abs(relcover - epsilon)))))

## TODO: add in zeroes for missing species
