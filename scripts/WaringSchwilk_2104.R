# Code by Elizabeth Waring
# Code for BBNP Drought project with Dylan Scwhilk
# data collected in 2010 and 2011 at Big Bend National Park


library(ggplot2)
library(nlme)
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
species2<-species #for table 3
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

#############################################################################
# Step 3:  Make subset for each gf


hist(tree.freq$pdieback, xlab="proportion of tree dieback", main=NULL)
hist(shrub.freq$pdieback,xlab="proportion of shrub dieback", main=NULL)
hist(subshrub.freq$pdieback,xlab="proportion of subshrub dieback", main=NULL)
hist(suc.freq$pdieback,xlab="proportion of succulent dieback", main=NULL)

hist(tree.freq$pdieback)

##############################################################################
# Step 4: Statistical Analysis

# for all species and gf together
# Nested transects when looking at effects of elevation and year on varible

# Total cover

# Test including GF in analysis ADDED 12-5
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(plants.tcover2$tcover)
# mixed effects model
lme.plants.tcover2 <- lme(tcover ~ elev*year*gf, random = ~1|elev,
                         data=plants.tcover2)
summary(lme.plants.tcover2)
anova(lme.plants.tcover2)
qplot(elev, tcover, data=plants.tcover2, color=year) + geom_smooth(method="lm")

plot(plants.tcover2$elev, resid(lme.plants.tcover2))

# Living Cover
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(plants.tcover$lcover)
# mixed effects model
lme.plants.lcover <- lme(lcover ~ elev*year, random = ~1|elev,
                         data=plants.tcover)
summary(lme.plants.lcover)
anova(lme.plants.lcover)
qplot(elev, lcover, data=plants.tcover, color=year) + geom_smooth(method="lm")

plot(plants.tcover$elev, resid(lme.plants.lcover))

#### For GF analysis
lme.plants.lcover2 <- lme(lcover ~ elev*year*gf, random = ~1|elev,
                         data=plants.tcover2)
summary(lme.plants.lcover2)
anova(lme.plants.lcover2)
qplot(elev, lcover, data=plants.tcover2, color=year) + geom_smooth(method="lm")

plot(plants.tcover$elev, resid(lme.plants.lcover2))


#For relative cover inlcuding gf
lme.plants.relcover <- lme(logPrelcover ~ elev*year*gf, random = ~1|elev,
                          data=plants.relcover)
summary(lme.plants.relcover)
anova(lme.plants.relcover)
qplot(elev, relcover, data=plants.relcover, color=year, shape=gf) + geom_smooth(method="lm")

plot(plants.tcover$elev, resid(lme.plants.lcover))


# logit transformed proportional dieback
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(totalDieback$logPdieback)
# mixed effects model
lme.logPdieback <-lme(logPdieback ~elev, random=~1|elev, data=totalDieback)
summary(lme.logPdieback)
anova(lme.logPdieback)
qplot(elev, logPdieback, data=totalDieback) +  geom_smooth(method="lm")
plot(totalDieback$elev, resid(lme.logPdieback))


# mixed effects model
lme.logPdieback2 <-lme(logPdieback ~elev*gf, random=~1|elev, data=dieback.2011)
summary(lme.logPdieback2)
anova(lme.logPdieback2)
qplot(elev, logPdieback, data=dieback.2011) +  geom_smooth(method="lm")
plot(dieback.2011$elev, resid(lme.logPdieback2))




#### TRAITS ##################################################################


# We will exclude succulents from the weighted LMA calculations, also these 
# data are from 2010 only

dieback.traits <-ddply(plants.cover2, .(elev, felev, ttrans, year, spcode, gf),
                       summarise,tdieback=sum(tdieback),
                       lcover=sum(lcover + 0.00001),
                       pdieback=mean(pdieback),
                       cover=mean(cover))

dieback.traits <-subset(dieback.traits, dieback.traits$year=="2011")

traits.die <- merge(traits, dieback.traits, by="spcode")
Suc<-traits.die
traits.die <- subset(traits.die, gf=="shrub" | gf=="subshrub" | gf == "tree")
noConifer<-subset(traits.die, spcode!="JUDEP")
noConifer<-subset(traits.die, spcode!="JUFLA") 
  noConifer<-subset(traits.die, spcode!="JUPIN")
  noConifer<-subset(traits.die, spcode!="PICEM")


## calculate mean weighted LMA at each site

traits.die1 <- ddply(traits.die, .(elev,felev, ttrans), summarize,
                    tdieback =mean(tdieback),
                    pdieback = mean(pdieback),
                    wLMA = weighted.mean(LMA, cover, na.rm = TRUE),
                    wLLMA=weighted.mean(LMA, lcover, na.rm = TRUE))
traits.die1$logPdieback <- log((traits.die1$pdieback - epsilon)/
        (1-(traits.die1$pdieback - epsilon)))

# with Suc
Suc <- ddply(Suc, .(elev,felev, ttrans), summarize,
                     tdieback =mean(tdieback),
                     pdieback = mean(pdieback),
                     wLMA = weighted.mean(LMA, cover, na.rm = TRUE),
                     wLLMA=weighted.mean(LMA, lcover, na.rm = TRUE))
Suc$logPdieback <- log((Suc$pdieback - epsilon)/
                                 (1-(Suc$pdieback - epsilon)))


# separate the elevations into two groups
highTraits<-subset(traits.die1, elev=="1920" | elev=="1690" |elev=="1411")
lowTraits<-subset(traits.die1, elev=="1132" | elev=="871" |elev=="666")
highTraits$group="high"
lowTraits$group="low"

allT<-merge(highTraits, lowTraits, all=T)

allT.lme<-lme(logPdieback ~ wLMA*group, random = ~ 1 | elev, 
                    data = allT)
summary(allT.lme)
anova(allT.lme)
qplot(wLMA, logPdieback, shape=group, data=allT) + geom_smooth(method="lm")
# separate the elevations into two groups


#traits by gf
traits.die2 <- ddply(traits.die, .(elev,felev, gf), summarize,
                    tdieback =mean(tdieback),
                    pdieback = mean(pdieback),
                    wLMA = weighted.mean(LMA, cover, na.rm = TRUE))

traits.die2$logPdieback <- log((traits.die2$pdieback - epsilon)/
                                 (1-(traits.die2$pdieback - epsilon)))
traits.die2<-na.omit(traits.die2)                         
# Statistics for traits data



logptraits.lme<-lme(logPdieback ~ wLMA*elev, random = ~ 1 | elev, 
                 data = traits.die1)
summary(logptraits.lme)
anova(logptraits.lme)
qplot(wLMA, logPdieback, data=traits.die1) + geom_smooth(method="lm")


# traits without conifers
noCon <- ddply(noConifer, .(elev,felev, ttrans), summarize,
                     tdieback =mean(tdieback),
                     pdieback = mean(pdieback),
                     wLMA = weighted.mean(LMA, cover, na.rm = TRUE),
                     wLLMA=weighted.mean(LMA, lcover, na.rm = TRUE))
noCon$logPdieback <- log((noCon$pdieback - epsilon)/
                                 (1-(noCon$pdieback - epsilon)))

noCon.lme<-lme(logPdieback ~ wLMA*elev, random = ~ 1 | elev, 
                    data = noCon)
summary(noCon.lme)
anova(noCon.lme)
qplot(wLMA, logPdieback, data=noCon) + geom_smooth(method="lm")

#no Conifers in two groups
highTraitsC<-subset(noCon, elev=="1920" | elev=="1690" |elev=="1411")
lowTraitsC<-subset(noCon, elev=="1132" | elev=="871" |elev=="666")
highTraitsC$group="high"
lowTraitsC$group="low"

allTC<-merge(highTraitsC, lowTraitsC, all=T)

allTC.lme<-lme(logPdieback ~ wLMA*group, random = ~ 1 | elev, 
              data = allTC)
summary(allTC.lme)
anova(allTC.lme)
qplot(wLMA, logPdieback, shape=group, data=allTC) + geom_smooth(method="lm")

# Trait stats by species


sptraits.lme<-lme(logPdieback~ gf , random = ~ 1 | elev, 
                 data = traits.die2)
summary(sptraits.lme)
anova(sptraits.lme)
qplot(pdieback, spcode, data=traits.die2) + geom_smooth(method="lm")

## Tables 3 and 4
# Table 3
dieByGF<-ddply(dieback.2011, .(elev, gf), summarize, pd_sd=sd(pdieback),
               pd=mean(pdieback))
totalPD<-ddply(dieback.2011, .(elev), summarize, pd_sd=sd(pdieback),
               pd=mean(pdieback))0
#table 4
dieback.traits11<-subset(dieback.traits, year=="2011")
dieBySPP<-ddply(dieback.traits11, .(elev, spcode, gf), summarize,
                pd_sd=sd(pdieback), 
                pd=mean(pdieback))
dieBySPP<-merge(dieBySPP, species2)
write.csv(dieByGF, "Table3Data.csv")
write.csv(dieBySPP, "Table4Data.csv")

# code for making figures in text and supplemental figures

# calculating the means and standard deviations for figures total.cover is
# used in figures 1 and 3

total.cover <- ddply(plants.cover, .(elev, year), summarize,
                     tcoversd=sd(tcover, na.rm=TRUE),
                     tcover=mean(tcover),
                     lcoversd=sd(lcover, na.rm=TRUE),
                     lcover=mean(lcover, na.rm=TRUE)
)
# the means of total.relcover used in figure 2
total.relcover<-ddply(plants.relcover,.(elev,gf, year), summarize, 
                      relcoversd=sd(logPrelcover),
                      relcover=mean(logPrelcover)
)
# the means and SD in die.total is used in figure 4

die.total <- ddply(dieback.2011, .(elev,gf), summarize,
                   logPdiebacksd=sd(logPdieback),
                   logPdieback=mean(logPdieback)
)

textsize <- 18
themeopts <- theme( axis.title.y = element_text(size = textsize, 
                                                angle = 90,vjust=0.3) ,
                    axis.title.x = element_text(size = textsize,
                                                vjust=-0.3),
                    panel.background = element_blank(), 
                    panel.border = element_rect(fill=NA), 
                    axis.text.x = element_text(size=16,color = "black"),
                    axis.text.y = element_text(size=16, color = "black"),
                    legend.title = element_text(size = 16),
                    legend.text = element_text(size = 16), 
                    strip.text.x = element_text(size = textsize), 
                    strip.text.y = element_text(size = textsize), 
                    strip.background = element_blank(),
                    legend.background=element_blank(),
                    legend.key = element_rect(fill = "white"))                                                                                                                                                                                                                                                                                                                                                                                                                                                


# Total Cover
ggplot(total.cover, aes(elev, tcover, shape=year, linetype=year)) +
  geom_pointrange(aes(ymin=tcover-tcoversd, ymax=tcover+tcoversd),size=1,
                  position = position_dodge(20))+
  #geom_smooth(method="lm", size=1,se=FALSE) +
  geom_abline(intercept=-0.3388674, slope=0.0006750, size=1) +
  geom_abline(intercept=-0.1995648, slope=0.0005231, size=1, color="gray50",
              linetype="dashed") +
  scale_x_continuous(breaks=c(750,1000,1250,1500,1750))+
  scale_linetype_discrete(name = "Year") +
  scale_shape_discrete(name = "Year") +
  labs(x="Elevation (m)") +
  labs(y="Total Cover") +
  themeopts +
  theme(legend.justification=c(1,0), legend.position=c(1,0),
        legend.background = element_rect(color="gray20", 
                                         linetype="solid", size=0.5))


ggsave(file="fig1-Tcover.png", dpi=300)


# total living cover
ggplot(total.cover, aes(elev, lcover, shape=year)) +
  geom_abline(intercept=-0.3555, slope=0.0006907, size=1, color="black") +
  geom_abline(intercept=-0.4795994, slope=0.0006315, size=1, 
              linetype="dashed", color="gray30") +
  geom_pointrange(aes(ymin=lcover-lcoversd, ymax=lcover+lcoversd),size=1,
                  position = position_dodge(20)) +
  labs(x="Elevation (m)") +
  labs(y="Total Living Cover")  +
  scale_x_continuous(breaks=c(750,1000,1250,1500,1750))+
  scale_linetype_discrete(name = "Year") +
  scale_shape_discrete(name = "Year") +
  themeopts +
  theme(legend.justification=c(1,0), legend.position=c(1,0),
        legend.background = element_rect(color="gray20", 
                                         linetype="solid", size=0.5))

ggsave("fig3-lCover.png", dpi=300)

##############################################################################
# Dieback figs

stat_sum_single <- function(fun, geom="point", ...) { 
  stat_summary(fun.y=fun, colour="black", geom=geom, size = 4, ...) 
} 

# function to add standard error of mean as error bars to a plot
se_bar <- function(){
  stat_summary(fun.data = 'mean_se', geom = 'errorbar', width = 0.2, size
               = 1)
}
ggplot(die.total, aes(elev, logPdieback)) +
  geom_smooth(method="lm",linetype="dashed", size=1, color = "gray20", 
              se=FALSE) +
  scale_x_continuous(breaks=c(750,1250,1750))+
  geom_pointrange(aes(ymin=logPdieback-logPdiebacksd, ymax=logPdieback+
                        logPdiebacksd),size=0.75, position = position_dodge(20))+
  facet_grid(.~gf) +
  labs(x="Elevation (m)") +
  labs(y="Proportional Dieback (logit)") +
  themeopts

ggsave("fig4-dieback.png", dpi=300)


#wLMA by dieback by elev
ggplot(traits.die1, aes(wLMA, logPdieback, shape=felev)) +
  stat_sum_single(mean) +
  labs(x="wLMA") +
  labs(y="Proportional Dieback (logit)") +
  scale_shape_discrete(name = "Elevation") +
  themeopts 


ggsave("fig5.wLMA2.png", dpi=300)

# Relcover all GF in 2010


relcover2010<-subset(total.relcover, total.relcover$year=="2010")
ggplot(relcover2010, aes(elev, relcover)) +
  geom_smooth(method="lm", linetype="dashed", size=1, color = "gray20",
              se=FALSE) +
  scale_x_continuous(breaks=c(750,1250,1750))+
  geom_pointrange(aes(ymin=relcover-relcoversd, ymax=relcover+  
                        relcoversd), size=0.75,position = position_dodge(20))+
  facet_grid(.~gf) +
  labs(x="Elevation (m)") +
  labs(y="Relative Cover (logit transformed)") +
  themeopts 

ggsave("fig2.relcover.png", dpi=300)

# Step 3:  Make dieback Frequency plots
freq=subset(plants.cover, plants.cover$year=="2011")

tree<-ggplot(freq, aes(pdieback)) +
  geom_histogram(data=subset(freq, gf=="tree" ),alpha=0.1,binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Tree Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts 
shrub<-ggplot(freq, aes(pdieback)) + 
  geom_histogram(data=subset(freq, gf=="shrub"), alpha=0.1,binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Shrub Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts
subshrub<- ggplot(freq, aes(pdieback)) + 
  geom_histogram(data=subset(freq, gf=="subshrub"), alpha=0.1, binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Subshrub Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts
suc <- ggplot(freq, aes(pdieback)) +
  geom_histogram(data=subset(freq, gf=="succulent"),alpha=0.1, binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Succulent Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts

grid.arrange(tree, shrub, subshrub, suc, nrow=2)
ggsave("freqDieback.png", dpi=300)


#figures for residuals

#total cover

residTC<-residTC+themeopts

ggsave("SF2.residualsTC.png", dpi=300)

#living cover

residLC<-residLC+themeopts

ggsave("SF4.residualsLC.png", dpi=300)

#total relative cover

residREL<-residREL+themeopts

ggsave("SF3.residualsREL.png", dpi=300)

#proportional dieback

residLogP<-residLogP+themeopts

ggsave("SF5.residualslogPdie.png", dpi=300)

#figure 5

residFig5<-residFig5+themeopts

ggsave("SF6.residualswLMA.png", dpi=300)

grid.arrange(residTC, residLC, residREL, residLogP, residFig5, ncol=3) 
