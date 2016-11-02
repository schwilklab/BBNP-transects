# figures.R
# Elizabeth Waring and Dylan Schwilk

# run dataShape.R first to produce summary data frames needed

source("./dataShape.R")

library(ggplot2)
#library(gridExtra)

pretty_name <- function(species) {
    parts <- str_match(species, "([A-Z])([a-z]+) ([a-z]+)")
    return(paste(parts[,2], parts[, 4], sep=". "))
}

# figure formatting

bestfit <- geom_smooth(method="lm",se = F, color = "black", size=1.5)
textsize <- 12
smsize <- textsize-2
fontfamily = "Arial"
themeopts <-   theme(axis.title.y = element_text(family=fontfamily,
                       size = textsize, angle = 90, vjust=0.3),
               axis.title.x = element_text(family=fontfamily, size = textsize, vjust=-0.3),
               axis.ticks = element_line(colour = "black"),
               panel.background = element_rect(size = 1.6, fill = NA),
               panel.border = element_rect(size = 1.6, fill=NA),
               axis.text.x  = element_text(family=fontfamily, size=smsize, color="black"),
               axis.text.y  = element_text(family=fontfamily, size=smsize, color = "black"),
               strip.text.x = element_text(family=fontfamily, size = smsize, face="italic"),
               strip.text.y = element_text(family=fontfamily, size = smsize, face="italic"),
               legend.title = element_text(family=fontfamily, size=textsize),
               legend.text = element_text(family=fontfamily, size=smsize, face="italic"),
               legend.key = element_rect(fill=NA),
               panel.grid.minor = element_blank(),
               panel.grid.major = element_blank(), #element_line(colour = "grey90", size = 0.2),
               strip.background = element_rect(fill = "grey80", colour = "grey50")      
               #panel.grid.major = element_line(colour = NA)
                )

## textsize <- 18
## themeopts <- theme( axis.title.y = element_text(size = textsize, 
##                                                 angle = 90,vjust=0.3) ,
##                     axis.title.x = element_text(size = textsize,
##                                                 vjust=-0.3),
##                     panel.background = element_blank(), 
##                     panel.border = element_rect(fill=NA), 
##                     axis.text.x = element_text(size=16,color = "black"),
##                     axis.text.y = element_text(size=16, color = "black"),
##                     legend.title = element_text(size = 16),
##                     legend.text = element_text(size = 16), 
##                     strip.text.x = element_text(size = textsize), 
##                     strip.text.y = element_text(size = textsize), 
##                     strip.background = element_blank(),
##                     legend.background=element_blank(),
##                     legend.key = element_rect(fill = "white"))  

stat_sum_single <- function(fun, geom="point", ...) {
  stat_summary(fun.y=fun, colour="black", geom=geom, size = 4, ...)
}

# function to add standard error of mean as error bars to a plot
se_bar <- function(){
  stat_summary(fun.data = 'mean_se', geom = 'errorbar', width = 0.2, size
               = 1)
}

## Tables
dieback.by.gf.summary <- ddply(gf.cover, .(year, elev, gf), summarize, pd_sd=sd(pdieback),
                         pd=mean(pdieback))

totalPD <- ddply(gf.cover, .(year, elev), summarize, pd_sd = sd(pdieback),
                 pd=mean(pdieback))

# Total Cover
ggplot(plants.cover, aes(elev, plants.cover)) +
    facet_grid(year ~ .) +
    geom_point() +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(750,1000,1250,1500,1750))+
    labs(x="Elevation (m)") +
    labs(y="Total Cover") +
    themeopts
ggsave(file="../results/total-cover.pdf")

# by year on x and facet by elev
ggplot(plants.cover, aes(year, plants.cover)) +
    facet_grid(. ~ felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Total Cover") +
    themeopts
ggsave(file="../results/total-cover2.pdf", width=16, height=8)

# total living cover
ggplot(plants.cover, aes(elev, plants.lcover)) +
    facet_grid(year ~ .) +
    geom_point() +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(750,1000,1250,1500,1750))+
    labs(x="Elevation (m)") +
    labs(y="Total Living Cover") +
    themeopts

# by year on x and facet by elev
ggplot(plants.cover, aes(year, plants.lcover)) +
    facet_grid(. ~ felev) +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
#    geom_point() +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Total Living Cover") +
    themeopts
ggsave(file="../results/total-living-cover.pdf", width=16, height=8)

# total living cover
ggplot(plants.cover, aes(elev, plants.lcover)) +
    facet_grid(year ~ .) +
    geom_point() +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(750,1000,1250,1500,1750))+
    labs(x="Elevation (m)") +
    labs(y="Total Living Cover") +
    themeopts

# by year on x and facet by elev
ggplot(plants.cover, aes(year, plants.lcover)) +
    facet_grid(. ~ felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Total Living Cover") +
    themeopts
ggsave(file="../results/total-living-cover.pdf", width=16, height=8)



#######################################################33
# Live cover by growth form
# by year on x and facet by elev
ggplot(gf.cover, aes(year, live.cover)) +
    facet_grid(felev ~ gf) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living Cover") +
    themeopts
ggsave(file="../results/live-cover-by-gf.pdf", width=16, height=8)

ggplot(subset(gf.cover, felev == "1920 m" ), aes(year, live.cover)) +
    facet_grid(gf ~ ., scales="free") +
    geom_point() +
    geom_boxplot(aes(group=year)) +
#    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living Cover") +
    themeopts
ggsave(file="../results/live-cover-by-gf-1920m.pdf", width=16, height=8)



# some subsets:
ggplot(subset(gf.cover, gf=="tree"), aes(year, live.cover)) +
    facet_grid(~ felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of trees") +
    themeopts
ggsave(file="../results/live-cover-trees.pdf")


ggplot(subset(gf.cover, gf=="tree" & felev == "1920 m" ), aes(year, live.cover)) +
    geom_boxplot(aes(group=year)) +
    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of trees") +
    themeopts
ggsave(file="../results/live-cover-trees-1920m.pdf")


# trees by species
species.cover$pretty.name <- pretty_name(species.cover$species)
ggplot(subset(species.cover, gf=="tree" & elev > 1500 & pretty.name != "NA. NA" ), aes(year, live.cover)) +
    facet_grid( . ~ pretty.name) +
    geom_boxplot(aes(group=year)) +
#    geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover") +
    themeopts
ggsave(file="../results/live-cover-trees-by-species.pdf")


# SHRUBS:
ggplot(subset(gf.cover, gf=="shrub"), aes(year, live.cover)) +
    facet_grid(~ felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of shrubs") +
    themeopts
ggsave(file="../results/live-cover-shrubs.pdf", width=16, height=8)

# SUCCULENTS:
ggplot(subset(gf.cover, gf=="succulent"), aes(year, live.cover)) +
    facet_grid(~ felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of succulents") +
    themeopts
ggsave(file="../results/live-cover-succulents.pdf", width=16, height=8)

# CACTI:
ggplot(subset(family.cover, family=="Cactaceae"), aes(year, live.cover)) +
    facet_grid(.~felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of cacti") +
    themeopts
ggsave(file="../results/live-cover-cacti.pdf", width=16, height=8)
# OAKS
ggplot(subset(family.cover, family=="Fagaceae" & elev==1920), aes(year, live.cover)) +
    #facet_grid(.~felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of oaks") +
    themeopts
ggsave(file="../results/live-cover-oaks.pdf", width=6, height=4)

# pines
ggplot(subset(family.cover, family=="Pinaceae" & elev==1920), aes(year, live.cover)) +
   # facet_grid(.~felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of pines") +
    themeopts
ggsave(file="../results/live-cover-pines.pdf", width=6, height=4)
# Junipers
ggplot(subset(family.cover, family=="Cupressaceae"), aes(year, live.cover)) +
    facet_grid(.~felev) +
    geom_point() +
    geom_boxplot(aes(group=year)) +
  #  geom_smooth(method="lm", se=FALSE) +
    scale_x_continuous(breaks=c(2010,2012,2014))+
    labs(x="Year") +
    labs(y="Living cover of junipers") +
    themeopts
ggsave(file="../results/live-cover-junipers.pdf")

##############################################################################
# Dieback figs

ggplot(subset(gf.cover, year > 2010), aes(elev, logitdieback)) +
  geom_boxplot(aes(group=elev))+
  geom_smooth(method="lm",linetype="dashed", size=1, color = "gray20", 
              se=FALSE) +
  scale_x_continuous(breaks=c(750,1250,1750))+
  facet_grid(year~gf) +
  labs(x="Elevation (m)") +
  labs(y="Proportional Dieback (logit)") +
  themeopts

ggsave("../results/dieback-by-gf-year.pdf")



# Relcover all GF all years
ggplot(gf.cover, aes(year, logitrelcover)) +
    facet_grid(gf ~ felev) +
    geom_boxplot(aes(group=year)) +
    labs(x="Year") +
    labs(y="Relative Cover (logit transformed)") +
    themeopts
## little change in relative cover.  Hmm


# Step 3:  Make dieback Frequency plots
gf_dieback_hist <- function(x, thegf) {
  return(
      ggplot(subset(x, gf==thegf & year > 2010), aes(x=pdieback)) +
          geom_histogram(aes(y = ..density..), binwidth=0.1) +
          facet_grid(.~ year) +
          labs(x=paste("Proportion of", thegf, "canopy dieback", y="Frequency")) +
          scale_x_continuous(limits=c(0,1))+
          themeopts)
     }


tree <- gf_dieback_hist(gf.cover, "tree")
shrub <- gf_dieback_hist(gf.cover, "shrub")
subshrub <- gf_dieback_hist(gf.cover, "subshrub")
succulent <- gf_dieback_hist(gf.cover, "succulent")

grid.arrange(tree, shrub, subshrub, succulent, nrow=2)
ggsave("../results/freqDieback.pdf")


