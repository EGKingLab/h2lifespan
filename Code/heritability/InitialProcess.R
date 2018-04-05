
############FUNCTIONS##########

source("../../Code/heritability/PreProcess_lifespan_functions.R")

############FUNCTIONS##########

library(tidyverse)

lifespan<-read.table('../../Data/Processed/lifespan_only.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE) %>%
  select(1, 2, 4:8, 12:16)

#calculate age (day)
lifespan$setDate <- as.Date(lifespan$setDate , "%m/%d/%y")
lifespan$flipDate <- as.Date(lifespan$flipDate , "%m/%d/%y")
lifespan_age <- (lifespan$flipDate - lifespan$setDate)
lifespan1 <- cbind(lifespan,lifespan_age)
lifespan1$age<-as.numeric(lifespan1$lifespan_age)
# all.equal(lifespan1$age, lifespan1$days)
# wh.diff<-lifespan1$age-lifespan1$days

#create separate columns for sire and dam ids
tempid <- strsplit(lifespan1$fID, split='_', fixed=TRUE)
tempid <- unlist(lapply(tempid, function(x) x[1])) 
tempid <- strsplit(tempid, split='D', fixed=TRUE) 
damid <- unlist(lapply(tempid, function(x) x[2]))
sireid <- unlist(lapply(tempid, function(x) x[1])) 
damid <- paste(rep('D', length(damid)), damid, sep='')

lifespan1$sireid <- sireid
lifespan1$damid <- damid

lifespan1[1,]
hist(lifespan1$age)

#Make unique ids
lifespan1$id <- paste(lifespan1$fID,'_',lifespan1$treat,sep='')

#Find dupicated samples
duplnames <- duplicate.ages(unique(lifespan1$id), lifespan1[,c('id','age')])
duplnames

# lifespan1 <- lifespan1[complete.cases(lifespan1[ , "age"]),]

#Age Check- skipped data entry (rows)

#Look for missing rows - Age gap >3 days
check.age <- age.check(unique(lifespan1$id), lifespan1[,c('id','age')])
dd<-lifespan1[,c('id','age')]
check.age
write.table(check.age,file='../../Data/Processed/omitedages.txt', sep='\t',row.names = FALSE)

#change NewAge
lifespan1$NewAge<-lifespan1$age+2

#Check if some letters in fID are in lower case (i.e. expect all names in upper case)
lifespan1 %in% letters

#write out cleaned data
write.table(lifespan1,file='../../Data/Processed/lifespan_correctedData.txt', sep='\t',row.names = FALSE)

################################


lifespan1<-read.table("../../Data/Processed/lifespan_correctedData.txt",sep="\t",stringsAsFactors=FALSE,header=TRUE)

#separate all events into rows
#females
Flife.dat<-lifespan1[,c('setDate','flipDate','age','NewAge','fID','id','sireid','damid','repl','treat','NstartF','deadF','carriedF')]
colnames(Flife.dat)[which(colnames(Flife.dat)=='deadF')]<-'Dead'
colnames(Flife.dat)[which(colnames(Flife.dat)=='carriedF')]<-'Carried'
Flife.dat<-Flife.dat[-which(is.na(Flife.dat$Dead)),]
Fevent<-Manip.Survival(Flife.dat)

#males
Mlife.dat<-lifespan1[,c('setDate','flipDate','age','NewAge','fID','id','sireid','damid','repl','treat','NstartM','deadM','carriedM')]
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='deadM')]<-'Dead'
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='carriedM')]<-'Carried'
Mlife.dat<-Mlife.dat[-which(is.na(Mlife.dat$Dead)),]
Mevent<-Manip.Survival(Mlife.dat)

#censored events
life.dat<-lifespan1[,c('setDate','flipDate','age','NewAge','id','cens')]
colnames(life.dat)[which(colnames(life.dat)=='cens')]<-'Censored'
life.dat<-life.dat[-which(is.na(life.dat$Censored)),]
Cevent<-Cen.events(life.dat)

####

totals <- CountEvents(lifespan1[-which(is.na(lifespan1$deadF)),])
max(totals$NCensor)
which.max(totals$NCensor)
totals[346, ]   # known case of escapes
subset(lifespan1, id==totals[which.max(totals$NCensor),'id'] & cens>0)

################################
#Account for censored events
totals$miss.f <- totals$NstartF-totals$NdeadF
totals$miss.m <- totals$NstartM-totals$NdeadM  

for(jj in 1:nrow(Cevent)) 
{
  miss.f<-totals[totals$id==Cevent$id[jj],'miss.f']
  miss.m<-totals[totals$id==Cevent$id[jj],'miss.m']
  
  
  if(miss.f>miss.m)
    {
      Fcol<-Fevent[Fevent$id==Cevent$id[jj],-which(colnames(Fevent) %in% colnames(Cevent))][1,]
      NewFev<-cbind(Fcol,Cevent[jj,])
      NewFev<-NewFev[,colnames(Fevent)]
      Fevent<-rbind(Fevent,NewFev)
      totals$miss.f[totals$id==Cevent$id[jj]]<-totals$miss.f[totals$id==Cevent$id[jj]]-1
    }else{
      if(miss.m>miss.f)
      {
        Mcol<-Mevent[Mevent$id==Cevent$id[jj],-which(colnames(Mevent) %in% colnames(Cevent))][1,]
        NewMev<-cbind(Mcol,Cevent[jj,])
        NewMev<-NewMev[,colnames(Mevent)]
        Mevent<-rbind(Mevent,NewMev)
        totals$miss.m[totals$id==Cevent$id[jj]]<-totals$miss.m[totals$id==Cevent$id[jj]]-1
        
      }else{
        #randomly choose
        if(sample(c(1,2),1)==1)
        {
          Fcol<-Fevent[Fevent$id==Cevent$id[jj],-which(colnames(Fevent) %in% colnames(Cevent))][1,]
          NewFev<-cbind(Fcol,Cevent[jj,])
          NewFev<-NewFev[,colnames(Fevent)]
          Fevent<-rbind(Fevent,NewFev)
          totals$miss.f[totals$id==Cevent$id[jj]]<-totals$miss.f[totals$id==Cevent$id[jj]]-1
          
        }else{
          Mcol<-Mevent[Mevent$id==Cevent$id[jj],-which(colnames(Mevent) %in% colnames(Cevent))][1,]
          NewMev<-cbind(Mcol,Cevent[jj,])
          NewMev<-NewMev[,colnames(Mevent)]
          Mevent<-rbind(Mevent,NewMev)
          totals$miss.m[totals$id==Cevent$id[jj]]<-totals$miss.m[totals$id==Cevent$id[jj]]-1
          
          
        }
      }
    }
      
   
  
}

length(Mevent$status[Mevent$status==3])+length(Fevent$status[Fevent$status==3])


totals$miss.m

Fevent[1,]

write.table(Fevent, "../../Data/Processed/Female_events_lifespan.txt", row.names=FALSE, sep="\t")
write.table(Mevent, "../../Data/Processed/Male_events_lifespan.txt", row.names=FALSE, sep="\t")

## End of script

lifespan1[1,]
lifespan1[1:5,]
lifespan1[lifespan1$Fcens==1,]
lifespan1[lifespan1$Mcens==1,]

hist((totals$NdeadF-totals$NstartF))

which.max((totals$NdeadF-totals$NstartF))
totals[235,]
totals$Fdiff<-totals$NdeadF-totals$NstartF
totals$Mdiff<-totals$NdeadM-totals$NstartM
subset(totals, Fdiff>5)
subset(totals, Fdiff< -5)
subset(lifespan1, id=='S17D50_b_STD')
subset(totals, NCensor>1)
