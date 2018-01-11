

Manip.Survival<-function(lifedat,N.start)
  #lifedat must have columns id, NewAge, Dead, Censored, Carried
{
  
  #get event indicies
  D.events<-which(lifedat$Dead!=0)
  Cen.events<-which(lifedat$Censored!=0)
  
  #set up output
  lifeInd<-lifedat[1,-which(colnames(lifedat) %in% c('Dead','Censored','Carried'))]
  lifeInd$status<-0
  lifeInd<-lifeInd[0,]
  
  for (i in 1:length(D.events))
  {
    ss<-lifedat[D.events[i],]
    NewAges<-sort(unique(lifedat[lifedat$ID==ss$ID,'NewAge']))
    if(ss$NewAge>min(NewAges))
    {
      #get data from previous NewAge
      #add NA if
      ss.prev<-subset(lifedat, ID==ss$ID & NewAge==NewAges[which(NewAges==ss$NewAge)-1])
      #print error if duplicated
      if(nrow(ss.prev)>1){stop("Duplicated NewAges-Run Data Check")}
      
      nDead<-ss$Dead-ss.prev$Carried
      
    }else{
      nDead<-ss$Dead
    }
    if(nDead>0)
    {
      dd<-lifedat[D.events[i],-which(colnames(lifedat) %in% c('Dead','Censored','Carried'))]
      #this is a way to replicate rows of a data frame
      #it is kind of like doing this dd<-dd[c(7,7,7,7,7),]
      dd<-dd[rep(row.names(dd),nDead),]
      
      #2 = dead
      dd$status<-rep(2,nDead)
      lifeInd<-rbind(lifeInd,dd)
    }
    
  }
  
  
  d.cen<-lifedat[Cen.events,]
  d.cen<-d.cen[rep(row.names(d.cen),d.cen[,'Censored']),-which(colnames(d.cen) %in% c('Dead','Censored','Carried'))]
  d.cen$status<-rep(3,nrow(d.cen))
  
  lifeInd<-rbind(lifeInd,d.cen)
  
  #still alive
  
  ids<-unique(lifedat$ID)
  
  err.ids<-data.frame("id"=character(length(ids)), "nevents"=numeric(length(ids)),stringsAsFactors=FALSE)
  
  for(j in 1:length(ids))
  {
    tt<-subset(lifedat, ID==ids[j])
    n.event<-length(lifeInd[lifeInd$ID==ids[j],'status'])
    
    err.ids[j,]<-c(ids[j],n.event)
    
    if(N.start<n.event)
    {
      N.total<-n.event
    }else{
      N.total<-N.start
    }
    if(n.event<N.start)
    {
      d.rest<-tt[,-which(colnames(tt) %in% c('Dead','Censored','Carried'))]
      d.rest<-d.rest[nrow(d.rest),]
      d.rest<-d.rest[rep(row.names(d.rest),N.total-n.event),]
      d.rest$status<-1
      lifeInd<-rbind(lifeInd,d.rest)
      
    }
  }
  return(list('dat'=lifeInd,'nevents'=err.ids))
  
}

#FUNCTIONS ABOVE##
########################
######################
######################

#check for errors

setwd('/Users/Enoch/Desktop/UMDesk/LifeHistory/Lifespan/Lifespan_LHGx/Analysis/')

#read in data

#lifedat<-read.table('LHGx2.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)
#lifedat<-read.table('LHGpx.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)
#lifedat<-read.table('LHGp3.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)
#meanlife<-read.table('rmean.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)
#lifedat<-read.table('Lifespan_pilot2_data.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)
lifedat<-read.table('lhgxmerge.txt',sep="\t",header=TRUE,stringsAsFactors=FALSE)

#remove any not numeric

lifedat<-subset(lifedat, Censored!= '>10')
lifedat$Censored<-as.integer(lifedat$Censored)
#treat<-strsplit(lifedat$ID,".",fixed=TRUE)
#lifedat$Treatment<-unlist(lapply(treat,function(x) x[1]))
#lifedat$Rep<-unlist(lapply(treat,function(x) x[2]))

lifedat$Rep<-lifedat$ID
lifedat$ID<-paste(lifedat$RIL,".",lifedat$Treatment,".",lifedat$Rep,sep="")
lifedat[1:10,]

#change NewAge
lifedat$NewAge<-lifedat$Age+2

#duplicate NewAges for a replicate

#get unique replicate ids
Uids<-unique(lifedat$ID)

dups.all<-lifedat[0,]
#loop through, find if duplicated, print ID and NewAge
for(ii in Uids)
{
  id.dat<-subset(lifedat, ID ==ii)
  if(anyDuplicated(id.dat$NewAge)!=0)
  {
    dups.all<-rbind(dups.all,id.dat[c(which(duplicated(id.dat$NewAge)),which(duplicated(id.dat$NewAge,fromLast=TRUE))),])
  }
  
}

dups.all<-dups.all[order(dups.all$RIL,dups.all$NewAge),]

write.table(dups.all, "duplicatedNewAges.txt",sep="\t",row.names=FALSE)


#remove NA rows

tester<-cbind(is.na(lifedat$Dead), is.na(lifedat$Carried), is.na(lifedat$Censored))
narows<-apply(tester,1,all)
if(length(which(narows))==0){
}else{
  lifedat<-lifedat[-which(narows),]
}
nass<-which(is.na(lifedat$Dead) | is.na(lifedat$Censored) | is.na(lifedat$Carried))
{
  print(lifedat[nass,])
}

#############################################################################################
library(survival)

#treat<-strsplit(lifedat$ID,".",fixed=TRUE)
#lifedat$Treatment<-unlist(lapply(treat,function(x) x[1]))
#lifedat$Rep<-unlist(lapply(treat,function(x) x[2]))

lifedat$Rep<-lifedat$ID
lifedat$ID<-paste(lifedat$RIL,".",lifedat$Treatment,".",lifedat$Rep,sep="")
lifedat[1:10,]


N.start<-30


#lifedat must have columns ID, NewAge, Dead, Censored, Carried
proc.data<-Manip.Survival(lifedat,N.start)
newdata<-proc.data$dat
nevents_by_id<-proc.data$nevents
subset(nevents_by_id, nevents>32)

newdata[1,]

##########################################################################################

#Write CSV in R
#write.csv(newdata, file = "lhgx2.csv")

#SURVIVAL ANALYSIS: KAPLAN-MEIER (K-M), #Non-parametic method
library(splines) #needed by survival packNewAge
library(ggplot2) #plotting
library(GGally) #for better looking plots in ggplot2 and automatic legend
library(KMsurv)

plot(newdata$RIL, newdata$Age)

###################################################################################
#mean survival sorted by treatment and then RIL
means <- aggregate(newdata$NewAge, by=list(newdata$Treatment), FUN=mean)
means
meansrils <- aggregate(newdata$NewAge, by=list(newdata$Treatment,newdata$RIL), FUN=mean)
meansrils
mrorder <- meansrils[order(meansrils$x),]
mrorder

barplot(meansrils$x, names.arg=meansrils$Group.2,
        col=c("red", "green"),
        title("Mean Survival Time in Weeks"))

barplot(meansrils$x, names.arg=c("meansrils$Group.2","meansrils$Group.1"),
        col=c("red", "green"),
        title("Mean Survival Time in Weeks"))

counts <- table(meansrils$x, meansrils$Group.2, meansrils$Group1)
barplot(counts, main="Survival time in weeks",
        xlab="RIL", col=c("darkblue","red"))

#SECOND APPROACH - data frame should contain means, RIL id, and std error columns

meanl <- meanlife$mean
ril <- meanlife$RILid
serrorm <- meanlife$Std..Err.
trt <- meanlife$treatment

#using lattice plot package (often comes with base installation)
# using col pallette heat.colors so that we have different color for different bars

require(lattice)
barchart (meanl~ ril|trt,
          layout = c(1,2),data=meanlife,#layout specifies # of rows and columns
          #aspect=.1, #try changing aspect value to see effect
          scales=list(x=list(cex=.5,rot=90, abbreviate=TRUE)), #change value of cex to change font size
          #col= heat.colors(2), 
          ylab = "Survival time (wk)", xlab = " RIL ")

x <- with(meanlife, reorder(trt,meanl,ril))

#scales=list(x=list(rot=45)) # changes oroentation of labels on x-axis
#"|factor(trt) separates by treatment

#using ggplot2
require(ggplot2)
survlife <- qplot(ril,meanl, geom="bar", fill = ril,color="black", ylab = "Mean survival (wk)", xlab = "RIL") + theme_bw()

# adding error bars
survlife + geom_errorbar(aes(ymin=meanl-serrorm, ymax=meanl+serrorm), width=.2, position=position_dodge(.1))
survlife + theme(legend.position="none") #removes legend
survlife + theme(axis.text.x = element_text(angle = 90, hjust = 1))


###################################################################################

msurv <- with(newdata, Surv(NewAge, status==2)) # 2=dead
mean(msurv) #gives incorrect value calculated from the whole matrix
mean(msurv[,1])
summary(msurv)

#Single stratum analysis # see ?Surv() ?survfit()
mfit <- survfit(Surv(NewAge, status == 2) ~ 1, data = newdata, conf.int = FALSE) #conf.type = "log-log" #Pointwise confidence intervals - see below
#conf ="none" 
#The log-log CI interval is preferred in K-M estimate
mfit

#Summaries
#summary(mfit)$surv #returns the K-M estimates at each t_i
#summary(mfit)$time # {t_i}
#summary(mfit$n.risk) # {Y_i}
#summary(mfit$n.event) # {d_i}
#summary(mfit$std.err) # stad error of the K-Mestimate at {t_i}
#summary(mfit$lower) # lower pointwise estimates (alternatively, $upper)
#str(mfit) # full summary of the mfit object
#str(summary(mfit)) # full summary of the mfit object
#summary(mfit, times=seq(14, 30, 60))

plot(mfit, mark.time=FALSE, lty=3, lwd=3, col="blue",pch=20,
     main="Kaplan-Meier estimate", 
     xlab="Time (days)", ylab="Survival Probability")

ggsurv(mfit, CI = FALSE,
       #CI = "def", #Defaults to TRUE for single stratum objects and FALSE for multiple strata objects.
       plot.cens = FALSE, #mark censored observations?
       surv.col = "gg.def", # Defaults to black for one stratum, and to the default ggplot2 colours for multiple strata.
       #cens.col = "red", 
       lty.est = 1, 
       #lty.ci = 2, #line type of confidence intervals
       #cens.shape = 3, #shape of points of censored obs.
       back.white = FALSE, #if TRUE the background will not be the default grey of ggplot2 but will be white with borders around the plot.
       xlab = "Time (days)", ylab = "Survival Probability", main = "Kaplan-Meier estimate")

#multi-stratum curve - by treatment
mfit1 <- survfit(Surv(NewAge, status == 2) ~ Treatment, data=newdata)
mfit1
summary(mfit1)
plot(mfit1,par(ps = 18, cex = 1, cex.main = 1))


plot(mfit1, mark.time = FALSE, lty = 2:3, col = c("red", "orange", "blue", "green"), lwd = 3,
     #main="Kaplan-Meier estimate", 
     xlab="Time (days)", ylab="Survival Probability")
legend(90, .9, c("CTRL", "DR", "StdF", "StdM"), lty = c(2:3), col = c("red", "orange", "blue", "green"), lwd = 3,
       title = "Treatment", bty = "n")

#FITTING THE COX's PROPORTIONAL HAZARD (a non-parametric model)
#Is Boxord (arrangement of vials in box) a risk factor i.e. does it iteract with Treatment? 
#coxph is used instead of survfit
modmfit1 <- coxph(Surv(NewAge,status==2)~strata(Treatment)*Boxord, data=newdata)
summary(modmfit1)


#Fit a simpler model with no interaction if interaction turns out not to be significant
modmfit2 <- coxph(Surv(NewAge,status==2)~strata(Treatment)+Boxord, data=newdata)
summary(modmfit2)
anova(modmfit1, modmfit2)
#If sou see no significant difference in explanatory power, accept the simpler model 
#without an interaction term. Note that removing the interaction may make the main 
#effect of Boxord significant

#plot(mfit1, mark.time = FALSE, lty = 2:3, col = c("blue", "green"), lwd = 3,
#main="Kaplan-Meier estimate", 
#     xlab="Time (days)", ylab="Survival Probability")
#legend(90, .9, c("StdF", "StdM"), lty = c(2:3), col = c("blue", "green"), lwd = 3,
#       title = "Treatment", bty = "n")

plot(mfit1, mark.time = FALSE, lty = 2:3, col = c("red", "orange"), lwd = 3,
     #main="Kaplan-Meier estimate", 
     xlab="Time (days)", ylab="Survival Probability")
legend(90, .9, c("CTRL", "DR"), lty = c(2:3), col = c("red", "orange"), lwd = 3,
       title = "Treatment", bty = "n")
#get median survival of curves
print(mfit1)
#or print(mfit1, show.rmean=TRUE)

# Mark the 50 % survival
abline(a=.5, b=0, lty=2)
abline(a=.1, b=0, lty=2)

mfit11 <- survdiff(Surv(NewAge, status == 2) ~ Treatment, data=newdata) # Log rank test
#mfit11 <- logrank_test(Surv(NewAge, status == 2) ~ Treatment, data=newdata)
mfit11

#multistratum in ggplot2
#(multi <- ggsurv(mfit1)) # this line works
mfit12 <- survival::survfit(Surv(NewAge, status==2) ~ Treatment, data = newdata)

mfit13 <- ggsurv(mfit12, plot.cens = FALSE, lty.est = 1, back.white = FALSE)+
  theme(legend.position="bottom", text=element_text(size=20), legend.direction="horizontal") +
  scale_fill_discrete("")
mfit13 


#Note1 the ggsurv function gives default colours to different strata
#Note2 ggplot2 creates a legend by default

#by RIL
mfit3 <- survfit(Surv(NewAge, status == 2) ~ RIL, data=newdata,
                 par(ps = 18, cex = 2, cex.main = 1))
mfit3
plot(mfit3)

#(multi <- ggsurv(mfit3))
mfit14 <- survival::survfit(Surv(NewAge, status==2) ~ RIL, data = newdata)
mfit141 <- ggsurv(mfit14, plot.cens = FALSE, lty.est = 1, back.white = FALSE,
                  xlab="Time (days)", ylab="Survival Probability")+
  theme(legend.position="bottom", text=element_text(size=20)) +
  scale_fill_discrete("")
#theme(legend.position="bottom", legend.direction="horizontal") +
#scale_fill_discrete("") +
mfit141 
mfit141 + theme(legend.position="none")

#group colours by Treatment
mfit14 + geom_line(data = newdata, aes(NewAge, RIL, group = Treatment),
                   col = 'darkblue', linetype = 1) +
  geom_point(data = newdata, aes(NewAge, RIL, group =Treatment), col = 'red')

######################################################################################

# HAZARD ANALYSIS
fun <- function(x) {1 - x} #cummulative probability plot

mort <- survfit(Surv(NewAge, status == 2) ~ Treatment, data=newdata, conf.type = "none") # survival
mort
plot(mort)
plot(mort, fun = function(x) {1 - x}, par(ps = 16, cex = 1, cex.main = 1)) #cummulative probability plot

mort1 <- muhaz(mort, fustat)
plot(mort1)
summary(mort1)

summary(mort, times=c(10,30,60,90,105))
(multi <- ggsurv(mort))
plot(mort, fun=function(x) {1-x})

plot(mfit1, mark.time = FALSE, lty = 2:3, col = c("blue", "green"), lwd = 3,
     #main="Kaplan-Meier estimate", 
     xlab="Time (days)", ylab="Survival Probability")
legend(90, .9, c("CTRL", "DR"), lty = c(2:3), col = c("blue", "green"), lwd = 3,
       title = "Treatment", bty = "n")

mfit11 <- survdiff(Surv(NewAge, status == 2) ~ Treatment, data=newdata) # Log rank test
#mfit11 <- logrank_test(Surv(NewAge, status == 2) ~ Treatment, data=newdata)
mfit11

mfit3 <- survfit(Surv(NewAge, status == 1) ~ Treatment, 
                 data = newdata, 
                 type = "kaplan-meier",
                 error = "greenwood",
                 conf.type = "log-log")
mfit3
plot(mfit3)

summary(mfit3, times=c(10,30,60,90,105))
(multi <- ggsurv(mfit3))
plot(mfit3, fun=function(x) {1-x})

#Total deaths

