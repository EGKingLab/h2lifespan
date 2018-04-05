library(tidyverse)

setwd("~/MyGithub/h2fecundspan/Code/heritability")

h2fecund <- read.csv('../../Data/Processed/merged_egg_counts.csv', header = TRUE, sep = ",")


# create "id" column from fID and treat
pp <- unite(h2fecund, "id", fID, treat, sep = "_", remove=FALSE)


ureps <- unique(h2fecund$id)

h2fecund$upN <- rep(NA, nrow(h2fecund))

h2fecund.t <- h2fecund[0,]


for(k in ureps)
{
  h2fecund.s <- subset(h2fecund, id==k)
  for(i in 1:nrow(h2fecund.s))
  {
   if(i == 1)
   {
     h2fecund.s[i,'upN'] <- h2fecund.s$NstartF[1]
   }else{
     if(is.na(h2fecund.s$deadF[i])|is.na(h2fecund.s$carriedF[(i-1)]))
     {
       h2fecund.s[i,'upN'] <- h2fecund.s[(i-1),'upN']
     }else{
     ndead <- h2fecund.s[i,'deadF']-h2fecund.s[(i-1),'carriedF']
     
     h2fecund.s[i,'upN'] <- h2fecund.s[(i-1),'upN']-ndead
     }#else close
   }#else close
  }#for i close
  h2fecund.t <- rbind(h2fecund.t, h2fecund.s)
}#for k close

h2fecund <- h2fecund.t

min(h2fecund$upN,na.rm=TRUE)
which(is.na(h2fecund$upN))
h2fecund[which(h2fecund$upN<0),]
#hist(h2fecund[which(h2fecund$upN<0),'upN'])


# set negative upN values to zero
h2fecund[h2fecund$upN<0,'upN']<-0
h2fecund[which(h2fecund$upN<0),]

h2fecund[h2fecund$id=="S19D55_b_HS", ]


# pull all Mondays from 2/29 to 6/20
# females present on each Monday are gave the eggs collected each Tuesday
Mondays <- as.Date("2016-02-29") #YYYY-MM-DD
weekdays(Mondays)
xm <- seq(Mondays, by="7 days", length.out=17)


# pull rows holding Monday and Tuesday flips
dd <- subset(h2fecund, flipDate %in% as.character(xm))











