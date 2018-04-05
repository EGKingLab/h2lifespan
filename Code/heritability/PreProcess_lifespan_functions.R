#function to look for duplicated ids

duplicate.ages<-function(Uids,dd)
  #Uids is unique vial id
  #dd is 2 columns, id is in column 1, age is in column 2
{
  dups.all<-dd[0,]
  #loop through, find if duplicated, print ID and age
  for(ii in Uids)
  {
    id.dat<-dd[dd[,1]==ii,]
    if(anyDuplicated(id.dat[,2])!=0)
    {
      dups.all<-rbind(dups.all,id.dat[c(which(duplicated(id.dat[,2])),which(duplicated(id.dat[,2],fromLast=TRUE))),])
      
    }
  }
  return(dups.all)
}

#check missing rows - identify these by age gap > 3 days

age.check <-function(Uids,dd)
  #Uids is unique vial id
  #dd is 2 columns, id is in column 1, age is in column 2
{
  dups.all<-dd[0,]
  #loop through, find if duplicated, print ID and age
  for(ii in Uids)
  {
    id.dat<-dd[dd[,1]==ii,]
    id.dat <- id.dat[order(id.dat[,2]),]
    max.diff <- max(diff(id.dat[,2]))
    if(max.diff > 3)
    {
      ww <- which(diff(id.dat[,2])>3)
      ww <- sort(c(ww,ww+1))
      dups.all<-rbind(dups.all,id.dat[ww,])
      
    }
    cat(ii,"\n")
  }
  return(dups.all)
}

##########################################
#This function counts numbers of dead be sex separately (deadF & deadM)
#subtracting numbers of 'carriedF and carriedM'
#The staring data frame should have these columns: id (unique id),age, deadF, 
#deadM, cens (censored cases), carriedF and carriedM


CountEvents<-function(lifedat)
{
  All.Ids<-unique(lifedat$id)
  
  
  
  #set up output
  TotalEvents<-data.frame('id'=All.Ids, 
                          'NstartF'=numeric(length(All.Ids)),
                          'NstartM'=numeric(length(All.Ids)),
                          'NdeadF'=numeric(length(All.Ids)),
                          'NdeadM'=numeric(length(All.Ids)),
                          'NCensor'=numeric(length(All.Ids)),stringsAsFactors=FALSE)
  for(ii in 1:length(All.Ids))
  {
    life.s<-subset(lifedat, id==All.Ids[ii])
    DF.events<-which(life.s$deadF!=0)
    DM.events<-which(life.s$deadM!=0)
    
    Fd<-0
    Md<-0
    
    #FEMALE EVENTS
    for (i in 1:length(DF.events))
    {
      ss<-life.s[DF.events[i],]
      NewAges<-sort(unique(life.s[,'NewAge']))
      if(ss$NewAge>min(NewAges))
      {
        #get data from previous NewAge
        #add NA if
        ss.prev<-subset(life.s, NewAge==NewAges[which(NewAges==ss$NewAge)-1])
        #print error if duplicated
        if(nrow(ss.prev)>1){stop("Duplicated NewAges-Run Data Check")}
        
        nDead<-ss$deadF-ss.prev$carriedF
        
      }else{
        nDead<-ss$deadF
      }
      Fd<-Fd+nDead
    }
    
    #MALE EVENTS
    for (i in 1:length(DM.events))
    {
      ss<-life.s[DM.events[i],]
      NewAges<-sort(unique(life.s[,'NewAge']))
      if(ss$NewAge>min(NewAges))
      {
        #get data from previous NewAge
        #add NA if
        ss.prev<-subset(life.s, NewAge==NewAges[which(NewAges==ss$NewAge)-1])
        #print error if duplicated
        if(nrow(ss.prev)>1){stop("Duplicated NewAges-Run Data Check")}
        
        nDead<-ss$deadM-ss.prev$carriedM
        
      }else{
        nDead<-ss$deadM
      }
      Md<-Md+nDead
    }
    TotalEvents[ii,'NstartF']<-life.s$NstartF[1]
    TotalEvents[ii,'NstartM']<-life.s$NstartM[1]
    TotalEvents[ii,'NdeadF']<-Fd
    TotalEvents[ii,'NdeadM']<-Md
    TotalEvents[ii,'NCensor']<-sum(as.numeric(life.s$cens))
    
  }
  return(TotalEvents)
}



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



