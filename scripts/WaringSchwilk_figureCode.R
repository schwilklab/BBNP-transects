#  Code by Elizabeth Waring
# Code for BBNP Drought project with Dylan Scwhilk
# data collected in 2010 and 2011 at Big Bend National Park
# This code was used for making figures for this paper
# Use varible names from WaringSchwilk_dataShape.R

source("./WaringSchwilk_dataShape.R")

library(ggplot2)
library(gridExtra)

# information used for figure formatting

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


## data needed for making tables 3 and 4

##Tables 3 and 4
# Table 3
dieByGF<-ddply(dieback.2011, .(elev, gf), summarize, pd_sd=sd(pdieback),
               pd=mean(pdieback))

totalPD<-ddply(dieback.2011, .(elev), summarize, pd_sd=sd(pdieback),
               pd=mean(pdieback))
#table 4

dieback.traits11<-subset(dieback.traits, year=="2011")

dieBySPP<-ddply(dieback.traits11, .(elev, spcode, gf), summarize,
                pd_sd=sd(pdieback), 
                pd=mean(pdieback))
dieBySPP<-merge(dieBySPP, species2)
write.csv(dieByGF, "../results/Table3Data.csv")
write.csv(dieBySPP, "../results/Table4Data.csv")

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

                                                                                                                                                                                                                                                                                                                                                                                                                                              


# Total Cover
ggplot(total.cover, aes(elev, tcover, shape=year, linetype=year)) +
  geom_pointrange(aes(ymin=tcover-tcoversd, ymax=tcover+tcoversd),size=1,
                  position = position_dodge(20))+
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

ggsave(file="../results/fig1-Tcover.png", dpi=300)


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

ggsave("../results/fig3-lCover.png", dpi=300)

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

ggsave("../results/fig4-dieback.png", dpi=300)


#wLMA by dieback by elev
ggplot(traits.die1, aes(wLMA, logPdieback, shape=felev)) +
  stat_sum_single(mean) +
  labs(x="wLMA") +
  labs(y="Proportional Dieback (logit)") +
  scale_shape_discrete(name = "Elevation") +
  themeopts 

ggsave("../results/fig5.wLMA2.png", dpi=300)

# Relcover all GF in 2010


relcover2010 <- subset(total.relcover, total.relcover$year=="2010")
ggplot(relcover2010, aes(elev, relcover)) +
  geom_smooth(method="lm", linetype="dashed", size=1, color = "gray20",
              se=FALSE) +
  scale_x_continuous(breaks=c(750,1250,1750))+
  geom_pointrange(aes(ymin=relcover-relcoversd, ymax=relcover+  
                        relcoversd), size=0.75,position = position_dodge(20)) +
  facet_grid(.~gf) +
  labs(x="Elevation (m)") +
  labs(y="Relative Cover (logit transformed)") +
  themeopts 

ggsave("../results/fig2.relcover.png", dpi=300)

# Step 3:  Make dieback Frequency plots
freq=subset(plants.cover, plants.cover$year=="2011")

tree <- ggplot(freq, aes(pdieback)) +
  geom_histogram(data=subset(freq, gf=="tree" ),alpha=0.1,binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Tree Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts 

shrub <- ggplot(freq, aes(pdieback)) + 
  geom_histogram(data=subset(freq, gf=="shrub"), alpha=0.1,binwidth=0.1,
                 colour="black", fill="white") +
  labs(x="Proportion of Shrub Canopy Dieback", y="Frequency") +
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits=c(0,20)) +
  themeopts

subshrub <- ggplot(freq, aes(pdieback)) + 
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
ggsave("../results/freqDieback.png", dpi=300)


# figures for residuals

## DWS: these all fail. residXXX objects do not exist

#total cover
residTC <- residTC + themeopts
ggsave("../results/SF2.residualsTC.png", dpi=300)

#living cover
residLC<-residLC+themeopts
ggsave("../results/SF4.residualsLC.png", dpi=300)

#total relative cover
residREL<-residREL+themeopts
ggsave("./results/SF3.residualsREL.png", dpi=300)

#proportional dieback
residLogP<-residLogP+themeopts
ggsave("./results/SF5.residualslogPdie.png", dpi=300)

#figure 5
residFig5<-residFig5+themeopts
ggsave("../results/SF6.residualswLMA.png", dpi=300)
grid.arrange(residTC, residLC, residREL, residLogP, residFig5, ncol=3)


