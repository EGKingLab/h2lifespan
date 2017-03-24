############FUNCTIONS##########
############FUNCTIONS##########
############FUNCTIONS##########

#Function to report missing values in a data frame
reportmiss <- function(Var){
  for (Var in names(lifec1)) {
    missing <- sum(is.na(lifec1[,Var]))
    if (missing > 0) {
      print(c(Var,missing))
    }
  }
}

#Summarize Missing Data for all Variables in a Data Frame
propmiss <- function(dataframe) {
  m <- sapply(dataframe, function(x) {
    data.frame(
      nmiss=sum(is.na(x)), 
      n=length(x), 
      propmiss=sum(is.na(x))/length(x)
    )
  })
  d <- data.frame(t(m))
  d <- sapply(d, unlist)
  d <- as.data.frame(d)
  d$variable <- row.names(d)
  row.names(d) <- NULL
  d <- cbind(d[ncol(d)],d[-ncol(d)])
  return(d[order(d$propmiss), ])
}


source("../../../Lifespan Functions/PreProcess_lifespan_functions.R")

############FUNCTIONS##########
############FUNCTIONS##########
############FUNCTIONS##########


#####################################################################

lifec<-read.table('feclife.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)

####################################
#eliminate excess columns
colnames(lifec)
lifec[17:28] <- list(NULL) #deletes unwanted colums 17-28
colnames(lifec)

###############################
#calculate age (day)
lifec$setDate <- as.Date(lifec$setDate , "%m/%d/%y")
lifec$flipDate <- as.Date(lifec$flipDate , "%m/%d/%y")
lifec_age <- (lifec$flipDate - lifec$setDate)
lifec1 <- cbind(lifec,lifec_age)
lifec1$age<-as.numeric(lifec1$lifec_age)
all.equal(lifec1$age, lifec1$days)
wh.diff<-lifec1$age-lifec1$days

#change NewAge
lifec1$NewAge<-lifec1$age+2

##################################
#create separate columns for sire and dam ids
tempid <- strsplit(lifec1$fID, split='_', fixed=TRUE) #splits id removing undesrcore foreward
tempid <- unlist(lapply(tempid, function(x) x[1])) 
tempid <- strsplit(tempid, split='D', fixed=TRUE) 
damid <- unlist(lapply(tempid, function(x) x[2]))
sireid <- unlist(lapply(tempid, function(x) x[1])) 
damid <- paste(rep('D', length(damid)), damid, sep='')

lifec1$sireid <- sireid
lifec1$damid <- damid


tail(lifec1)

lifec1[1,]
head(lifec1,4)
hist(lifec1$age)

#########
#Make unique ids
lifec1$id <- paste(lifec1$fID,'_',lifec1$treat,sep='')

#############################
#Find NAs in the data
lifec1_na <- which(is.na(lifec1))

#Find missing values & problematic cells
lifec2 <- reportmiss(lifec1)
reportmiss(lifec2)

#Proportion of missing values in the data frame
lifec3 <- propmiss(lifec1)
propmiss(lifec3)

#Find NAs in the data
#isNA <- which(is.na(lifec1))
anyNA(lifec1) #i.e. any(is.na(x))
which(anyNA(lifec1))



#################################
#Find dupicated samples

duplnames <- duplicate.ages(unique(lifec1$id), lifec1[,c('id','age')])
duplnames

################################
#Age Check- skipped data entry (rows)

#Look for missing rows - Age gap >3 days
check.age <- age.check(unique(lifec1$id), lifec1[,c('id','age')])
dd<-lifec1[,c('id','age')]
check.age
write.table(check.age,file='omitedages.txt', sep='\t',row.names = FALSE)

#################################
#Check if some letters in fID are in lower case (i.e. expect all names in upper case)
lifec1 %in% letters
# %in% searchvalue matching i.e. eturns a logical vector indicating if there is a match 
#or not for its left operand. 
# syntax: match(x, table, nomatch = NA_integer_, incomparables = NULL)
# is same as: x %in% table i.e. matches x against table

#################################
#write out cleaned data
write.table(lifec1,file='lifespan_correctedData.txt', sep='\t',row.names = FALSE)

################################


lifec1<-read.table("lifespan_correctedData.txt",sep="\t",stringsAsFactors=FALSE,header=TRUE)

#separate all events into rows
#females
Flife.dat<-lifec1[,c('setDate','flipDate','days','age','NewAge','fID','id','sireid','damid','repl','treat','NstartF','deadF','carriedF')]
colnames(Flife.dat)[which(colnames(Flife.dat)=='deadF')]<-'Dead'
colnames(Flife.dat)[which(colnames(Flife.dat)=='carriedF')]<-'Carried'
Flife.dat<-Flife.dat[-which(is.na(Flife.dat$Dead)),]
Fevent<-Manip.Survival(Flife.dat)
#males
Mlife.dat<-lifec1[,c('setDate','flipDate','days','age','NewAge','fID','id','sireid','damid','repl','treat','NstartM','deadM','carriedM')]
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='deadM')]<-'Dead'
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='carriedM')]<-'Carried'
Mlife.dat<-Mlife.dat[-which(is.na(Mlife.dat$Dead)),]
Mevent<-Manip.Survival(Mlife.dat)

#censored events
life.dat<-lifec1[,c('setDate','flipDate','days','age','NewAge','id','cens')]
colnames(life.dat)[which(colnames(life.dat)=='cens')]<-'Censored'
life.dat<-life.dat[-which(is.na(life.dat$Censored)),]
Cevent<-Cen.events(life.dat)

####

totals <- CountEvents(lifec1[-which(is.na(lifec1$deadF)),])
max(totals$NCensor)
which.max(totals$NCensor)
totals[346, ]
subset(lifec1, id==totals[which.max(totals$NCensor),'id'] & cens>0)

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

write.table(Fevent, "Female_events_lifespan.txt", row.names=FALSE, sep="\t")
write.table(Mevent, "Male_events_lifespan.txt", row.names=FALSE, sep="\t")

## End of script

lifec1[1,]
lifec1[1:5,]
lifec1[lifec1$Fcens==1,]
lifec1[lifec1$Mcens==1,]

hist((totals$NdeadF-totals$NstartF))

which.max((totals$NdeadF-totals$NstartF))
totals[235,]
totals$Fdiff<-totals$NdeadF-totals$NstartF
totals$Mdiff<-totals$NdeadM-totals$NstartM
subset(totals, Fdiff>5)
subset(totals, Fdiff< -5)
subset(lifec1, id=='S17D50_b_STD')
subset(totals, NCensor>1)
