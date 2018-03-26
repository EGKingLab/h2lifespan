# script changes values for a specific id

M <- read_excel("../../Data/Processed/feclife_with-image-ids.xlsx")
M <- readit::readit("../../Data/Processed/feclife_with-image-ids.xlsx")

# make unique ids
M <- unite(M, "id", fID, treat, sep = "_", remove=FALSE)

# needed for code to run
M$setDate <- as.character(M$setDate)
M$flipDate <- as.character(M$flipDate)

# change NstartF for all S19D55_a_HS cases to 15
M <- M %>% 
  mutate(NstartF = replace(NstartF, which(id=="S11D33_a_LY"), 15))


write_csv(M, path = "../../Data/Processed/feclife_with-image-ids.csv")
