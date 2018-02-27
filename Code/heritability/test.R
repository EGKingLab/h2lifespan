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

h2life[h2life$upN<0,'upN']<-0








#source("../../Code/heritability/PreProcess_lifespan_functions.R")


# females present on each Monday are responsible for eggs collected Tuesday
# all Mondays from 2/29 to 6/20
Mondays <- as.Date("2016-02-29") #YYYY-MM-DD
weekdays(Mondays)
xm <- seq(Mondays, by="7 days", length.out=17)


h2life[, 'flipDate'] <- as.factor(h2life[, 'flipDate'])

# filter rows holding Monday and Tuesday flips
dd <- subset(h2life, flipDate %in% c("2016-02-29","2016-03-07","2016-03-14","2016-03-21","2016-03-28","2016-04-04","2016-04-11","2016-04-18",
                                 "2016-04-25","2016-05-02","2016-05-09","2016-05-16","2016-05-23","2016-05-30","2016-06-06","2016-06-13",
                                 "2016-06-20"))

dd1 <- subset(h2life, flipDate %in% cat(xm))
# dd2<-dd[,c('setDate','flipDate','age','NewAge','fID','id','sireid','damid','repl','treat','NstartF','deadF','carriedF','cens')]



#identify carrieds & count dead on each row (test with one vial)
oneVial <- dd2[dd2$id=="S19D55_b_HS", ]

## set up output
oneVial$ddnCarrd <- 0   # dead plus carried

for (i in 1:length(oneVial$deadF))
{
  oneVial$ddnCarrd[(i+1)] <- oneVial$deadF[(i+1)]-oneVial$carried[i]
  
}

# account for censored
# assume cens are female since there are 2-4 times more females in a vial
  
ddnCens <- 0

for (j in 1:length(oneVial$cens)) 
{
  oneVial$ddnCens[j] <- oneVial$ddnCarrd[j]+oneVial$cens[j]
  
}

# number of females on successive Tuesdays
upN <- 0  # NstartF updated
#nNew <- 0   
#N <- oneVial[jj,]

for (jj in 1:length(oneVial$ddnCens))
{
  # oneVial$upN[jj+1] <- oneVial$NstartF[jj-]-oneVial$ddnCens[jj-1]
  #oneVial$upN[1] <- oneVial$NstartF[1]
  oneVial$upN[jj] <- oneVial$upN[1]-oneVial$ddnCens[jj]
  oneVial$upN[jj+1] <- oneVial$upN[jj]-oneVial$upN[jj+1]
}








