library(tidyverse)

setwd("~/MyGithub/h2lifespan/Code/heritability")

h2life <- read.table('../../Data/Processed/lifespan_correctedData.txt',
                     sep = "\t", header = TRUE,
                     stringsAsFactors = FALSE)


ureps <- unique(h2life$id)

h2life$upN <- rep(NA, nrow(h2life))

h2life.t <- h2life[0,]


for(k in ureps)
{
  h2life.s <- subset(h2life, id==k)
  for(i in 1:nrow(h2life.s))
  {
   if(i == 1)
   {
     h2life.s[i,'upN'] <- h2life.s$NstartF[1]
   }else{
     if(is.na(h2life.s$deadF[i])|is.na(h2life.s$carriedF[(i-1)]))
     {
       h2life.s[i,'upN'] <- h2life.s[(i-1),'upN']
     }else{
     ndead <- h2life.s[i,'deadF']-h2life.s[(i-1),'carriedF']
     
     h2life.s[i,'upN'] <- h2life.s[(i-1),'upN']-ndead
     }#else close
   }#else close
  }#for i close
  h2life.t <- rbind(h2life.t, h2life.s)
}#for k close

h2life <- h2life.t

min(h2life$upN,na.rm=TRUE)
which(is.na(h2life$upN))
h2life[which(h2life$upN<0),]
hist(h2life[which(h2life$upN<0),'upN'])


# set negative upN values to zero
h2life[h2life$upN<0,'upN']<-0
h2life[which(h2life$upN<0),]

h2life[h2life$id=="S19D55_b_HS", ]


# pull all Mondays from 2/29 to 6/20
# females present on each Monday are gave the eggs collected each Tuesday
Mondays <- as.Date("2016-02-29") #YYYY-MM-DD
weekdays(Mondays)
xm <- seq(Mondays, by="7 days", length.out=17)


# pull rows holding Monday and Tuesday flips
dd <- subset(h2life, flipDate %in% as.character(xm))
dd <- unite(dd, "flipD_id", flipDate, fID, treat, sep = "_", remove=FALSE)

ddm <- select(dd, flipD_id, upN)

#MM_ddm_join <- left_join(MM, ddm, by = c("flipDate", "id"))












