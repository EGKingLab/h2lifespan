

Manip.Survival<-function(lifedat)
  #lifedat must have columns id, NewAge, Dead, Carried
{
  
  #get event indicies
  D.events<-which(lifedat$Dead!=0)

  #set up output
  lifeInd<-lifedat[1,-which(colnames(lifedat) %in% c('Dead','Carried'))]
  lifeInd$status<-0
  lifeInd<-lifeInd[0,]
  
  for (i in 1:length(D.events))
  {
    ss<-lifedat[D.events[i],]
    NewAges<-sort(unique(lifedat[lifedat$id==ss$id,'NewAge']))
    if(ss$NewAge>min(NewAges))
    {
      #get data from previous NewAge
      #add NA if
      ss.prev<-subset(lifedat, id==ss$id & NewAge==NewAges[which(NewAges==ss$NewAge)-1])
      #print error if duplicated
      if(nrow(ss.prev)>1){stop("Duplicated NewAges-Run Data Check")}
      
      nDead<-ss$Dead-ss.prev$Carried
      
    }else{
      nDead<-ss$Dead
    }
    if(nDead>0)
    {
      dd<-lifedat[D.events[i],-which(colnames(lifedat) %in% c('Dead','Carried'))]
      #this is a way to replicate rows of a data frame
      #it is kind of like doing this dd<-dd[c(7,7,7,7,7),]
      dd<-dd[rep(row.names(dd),nDead),]
      
      #2 = dead
      dd$status<-rep(2,nDead)
      lifeInd<-rbind(lifeInd,dd)
    }
    
  }
  
  return(lifeInd)
  
}



Cen.events<-function(lifedat)
  #lifedat must have columns id, NewAge, Censored
{
  
  #get event indicies
  Cen.events<-which(lifedat$Censored!=0)
  
  #set up output
  lifeInd<-lifedat[1,-which(colnames(lifedat) %in% c('Censored'))]
  lifeInd$status<-0
  lifeInd<-lifeInd[0,]
  
  d.cen<-lifedat[Cen.events,]
  d.cen<-d.cen[rep(row.names(d.cen),d.cen[,'Censored']),-which(colnames(d.cen) %in% c('Censored'))]
  d.cen$status<-rep(3,nrow(d.cen))
  
  lifeInd<-rbind(lifeInd,d.cen)
  return(lifeInd)
  
}





#FUNCTIONS ABOVE##
########################
######################
######################


lifec1<-read.table(file='lifespan_correctedData.txt', sep='\t',stringsAsFactors=FALSE,header=TRUE)

Flife.dat<-lifec1[,c('setDate','flipDate','days','age','NewAge','fID','id','sireid','damid','repl','treat','NstartF','deadF','carriedF')]
colnames(Flife.dat)[which(colnames(Flife.dat)=='deadF')]<-'Dead'
colnames(Flife.dat)[which(colnames(Flife.dat)=='carriedF')]<-'Carried'
Flife.dat<-Flife.dat[-which(is.na(Flife.dat$Dead)),]
Fevent<-Manip.Survival(Flife.dat)

Mlife.dat<-lifec1[,c('setDate','flipDate','days','age','NewAge','fID','id','sireid','damid','repl','treat','NstartM','deadM','carriedM')]
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='deadM')]<-'Dead'
colnames(Mlife.dat)[which(colnames(Mlife.dat)=='carriedM')]<-'Carried'
Mlife.dat<-Mlife.dat[-which(is.na(Mlife.dat$Dead)),]
Mevent<-Manip.Survival(Mlife.dat)

life.dat<-lifec1[,c('setDate','flipDate','days','NewAge','id','cens')]
colnames(life.dat)[which(colnames(life.dat)=='cens')]<-'Censored'
life.dat<-life.dat[-which(is.na(life.dat$Censored)),]
Cevent<-Cen.events(life.dat)





