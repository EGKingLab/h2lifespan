library(MCMCglmm)
library(tidyverse)
library(readxl)

data <- read_excel("dryad.xlsx") %>% as.data.frame()

# data<-read.table("gxe.txt", h=T,
#                  colClasses=c("numeric",rep("factor",4),rep("numeric",3)))
# attach(data)
str(data)

males<-data[data$Sex=="M",]
females<-data[data$Sex=="F",]

fam<-rep("gaussian", 3)
                         
## male model: CHCs ~ Food*Temp + Food*Isoline + Temp*Isoline ; DIC 14968.1
                
prior.10 <- list( R=list(V=diag(3)/3, nu=0.02),  G=list(G1=list(V=diag(9)/9, nu=0.02)))
fmla.10 <- as.formula(paste("cbind(CHC.1,CHC.2,CHC.3)" ,"~", " trait + trait:Temperature + trait:Diet + trait:Diet:Temperature -1 "))
m.10 <- MCMCglmm(fmla.10,random=~ idh(trait+trait:Diet+trait:Temperature):Isoline,
                rcov=~ idh(trait):units, 
                prior=  prior.10,data= males, family= fam,  nitt= 200000, burnin= 10000,   thin=30, pr=F)
 
## genetic correlation
colnames(m.10$VCV)[4]
colnames(m.10$VCV)[1]
colnames(m.10$VCV)[22]


corr<-m.10$VCV[,4] / (sqrt(m.10$VCV[,1] * m.10$VCV[,22]))
summary(corr)

## heritability
h2<-2*m.10$VCV[,4]/(m.10$VCV[,1]+m.10$VCV[,22])
summary(h2)
                
## female model: CHCs ~ Food*Temp + Food*Isoline + Temp*Isoline ; DIC 13903.59

prior.9 <- list( R=list(V=diag(3)/3, nu=0.02),  G=list(G1=list(V=diag(9)/9, nu=0.02)))
fmla.9 <- as.formula(paste("cbind(PC1,PC2,PC3)" ,"~", " trait + trait:Temperature + trait:Food + trait:Food:Temperature -1 "))
f.9 <- MCMCglmm(fmla.9,random=~ idh(trait+trait:Temperature+trait:Food):Isoline,
                rcov=~ idh(trait):units, 
                prior=  prior.9,data= females, family= fam,  nitt= 200000, burnin= 10000,   thin=30, pr=F)
             
## genetic correlation               
corr<-f.9$VCV[,4]/(sqrt(f.9$VCV[,1]*f.9$VCV[,22]))
summary(corr)

## heritability
h2<-2*f.9$VCV[,4]/(f.9$VCV[,1]+f.9$VCV[,22])
summary(h2)  
