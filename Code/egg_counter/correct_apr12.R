# Locate section of lifespan_only.txt that was a frameshift copying error

library(readxl)
library(tidyverse)

lifespan <- read.table('../../Data/Processed/lifespan_only.txt',
                       sep = "\t", header = TRUE,
                       stringsAsFactors = FALSE)
M <- read_excel("../../Data/Processed/feclife_with-image-ids.xlsx")
M$id <- paste(M$fID, "_", M$treat, sep = "")

lifespan$flipDate <- as.Date(lifespan$flipDate, "%m/%d/%y")
lifespan$id <- paste(lifespan$fID, "_", lifespan$treat, sep = "")
dates <- unique(M$flipDate)

a12f <- M[M$flipDate == dates[8], ]

a12f <- a12f[-which(is.na(a12f[ , 1])) , ]

a12l <- lifespan[lifespan$flipDate == dates[8], ]

all <- merge(a12f, a12l, by = c('fID', 'treat'), sort = FALSE)
which(!(a12f$id %in% all$id.x))
which(!(a12l$id %in% all$id.y))
all <- all[order(all$camera_id),]
write.table(all,
            file = "../../Data/Processed/Error_April12correct.txt",
            sep = "\t", row.names = FALSE)

#all <- all[order(all$box.y,all$ccoord.y,all$rcoord.y),]
#all <- all[order(all$box.x,all$ccoord.x,all$rcoord.x),]

colnames(all)
all[1:10, c('fID', 'treat', 'NstartF.x', 'NstartF.y',
            'deadF.x', 'deadF.y')]
all.equal(all$NstartF.x, all$NstartF.y)
which((all$NstartF.x - all$NstartF.y) != 0)

colnames(M)

#newM <- all[,c('camera_id','handcounted','handcount','test_case','visually_recheck',
#               'setDate','flipDate','')]

ll<- sort(unique(lifespan$id))
mm<-sort(unique(M$id))
ll[which(!ll%in%mm)]
mm[which(!mm%in%ll)]

lifespan[lifespan$fID=="S37D111_a",]

ch.f <- M %>% group_by(id) %>%
  dplyr::summarise('dfem' = n_distinct(NstartF))
ii <- ch.f[which(ch.f$dfem > 1), ]

as.data.frame(M[M$id == ii$id[1],])
as.data.frame(M[M$id == ii$id[2],])
as.data.frame(M[M$id == ii$id[3],])
as.data.frame(M[M$id == ii$id[4],])
as.data.frame(M[M$id == ii$id[5],])
as.data.frame(M[M$id == ii$id[6],])
as.data.frame(M[M$id == ii$id[7],])
