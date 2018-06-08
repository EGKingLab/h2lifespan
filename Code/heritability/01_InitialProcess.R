
############FUNCTIONS##########

source("../../Code/heritability/PreProcess_lifespan_functions.R")

############FUNCTIONS##########

library(tidyverse)

lifespan<-read.table('../../Data/Processed/lifespan_only.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE) %>%
  select(1:16)

#calculate age (day)
lifespan$setDate <- as.Date(lifespan$setDate , "%m/%d/%y")
lifespan$flipDate <- as.Date(lifespan$flipDate , "%m/%d/%y")
lifespan_age <- (lifespan$flipDate - lifespan$setDate)
lifespan <- cbind(lifespan,lifespan_age)
lifespan$age<-as.numeric(lifespan$lifespan_age)
# all.equal(lifespan$age, lifespan$days)
# wh.diff<-lifespan$age-lifespan$days

#create separate columns for sire and dam ids
tempid <- strsplit(lifespan$fID, split='_', fixed=TRUE)
tempid <- unlist(lapply(tempid, function(x) x[1])) 
tempid <- strsplit(tempid, split='D', fixed=TRUE) 
damid <- unlist(lapply(tempid, function(x) x[2]))
sireid <- unlist(lapply(tempid, function(x) x[1])) 
damid <- paste(rep('D', length(damid)), damid, sep='')

lifespan$sireid <- sireid
lifespan$damid <- damid

lifespan[1,]
hist(lifespan$age)

#Make unique ids
lifespan$id <- paste(lifespan$fID,'_',lifespan$treat,sep='')

#Find dupicated samples
duplnames <- duplicate.ages(unique(lifespan$id), lifespan[,c('id','age')])
duplnames

# lifespan <- lifespan[complete.cases(lifespan[ , "age"]),]

#Age Check- skipped data entry (rows)

#Look for missing rows - Age gap >3 days
check.age <- age.check(unique(lifespan$id), lifespan[,c('id','age')])
dd<-lifespan[,c('id','age')]
check.age
#write.table(check.age,file='../../Data/Processed/omitedages.txt', sep='\t',row.names = FALSE)

#change NewAge
lifespan$NewAge<-lifespan$age+2

#Check if some letters in fID are in lower case (i.e. expect all names in upper case)
lifespan %in% letters

#write out cleaned data
write.table(lifespan,file='../../Data/Processed/lifespan_correctedData.txt', sep='\t',row.names = FALSE)

################################


lifespan<-read.table("../../Data/Processed/lifespan_correctedData.txt",sep="\t",stringsAsFactors=FALSE,header=TRUE)

#separate all events into rows
#females
Flife.dat<-lifespan[,c('setDate','flipDate','age','NewAge','fID','id','sireid','damid','repl','treat','NstartF','deadF','carriedF')]
colnames(Flife.dat)[which(colnames(Flife.dat)=='deadF')]<-'Dead'
colnames(Flife.dat)[which(colnames(Flife.dat)=='carriedF')]<-'Carried'
Flife.dat<-Flife.dat[-which(is.na(Flife.dat$Dead)),]
Fevent<-Manip.Survival(Flife.dat)

#males
Mlife.dat<-lifespan[,c('setDate','flipDate','age','NewAge','fID','id','sireid','damid','repl','treat','NstartM','deadM','carriedM')]
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='deadM')]<-'Dead'
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='carriedM')]<-'Carried'
Mlife.dat<-Mlife.dat[-which(is.na(Mlife.dat$Dead)),]
Mevent<-Manip.Survival(Mlife.dat)

#censored events
life.dat<-lifespan[,c('setDate','flipDate','age','NewAge','id','cens')]
colnames(life.dat)[which(colnames(life.dat)=='cens')]<-'Censored'
life.dat<-life.dat[-which(is.na(life.dat$Censored)),]
Cevent<-Cen.events(life.dat)

####

totals <- CountEvents(lifespan[-which(is.na(lifespan$deadF)),])
max(totals$NCensor)
which.max(totals$NCensor)
totals[346, ]   # known case of escapes
subset(lifespan, id==totals[which.max(totals$NCensor),'id'] & cens>0)

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

