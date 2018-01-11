# devtools::install_github("dgrtwo/broom")
library(doParallel)
library(tictoc)

library(tidyverse)
library(readxl)
library(cowplot)
library(broom)
library(forcats)
library(ggrepel)

outfile <- "CVs_fine_final.csv"
infile <- "area_summation_fine.csv"

rootDir <- "hd_hand_counted_masked"

# areas estimated from thresholding
areas <- read_csv(file.path(rootDir, infile),
                  col_types = "cii")

# handcounts
actual <- read_excel("../hd_hand_counted/hd_hand_counted.xlsx") %>% 
  filter(status != "bad") %>% 
  select(cameraid, handcount)

# Check for mismatches
area_ids <- unique(areas$cameraid)
actual_ids <- unique(actual$cameraid)
area_not_in_actual <- area_ids[!(area_ids %in% actual_ids)]
actual_not_in_area <- actual_ids[!(actual_ids %in% area_ids)]
message("Files not found in handcount.")
print(area_not_in_actual)
message("Handcounts not found in JPG file list.")
print(actual_not_in_area)

M <- full_join(areas, actual, by = "cameraid") %>% 
  drop_na() %>% 
  mutate(area = log(area),
         handcount = log(handcount))

#########################################################################

area_rarefaction <- function(M, lower,
                             prop_data,
                             prop_train,
                             iters = 1000){
  library(tidyverse)
  M_sub <- filter(M, lower_thresh == lower)
  M_sub <- M_sub[sample(1:nrow(M_sub), trunc(prop_data * nrow(M_sub))), ]
  
  # Empty tibble to hold cross-validation output
  cv <- tibble(
    r = numeric(iters),
    MSD = numeric(iters)
  )
  
  for (ii in 1:iters) {
    # Create list of rows for train/test
    samps <- sample(1:nrow(M_sub), trunc(prop_train * nrow(M_sub)))
    
    # Subset rows into train/test
    tr <- M_sub[samps, ]
    te <- M_sub[-samps, ]
    
    # Fit model on training set
    fm <- lm(handcount ~ area, tr)
    te$pred <- predict(fm, te)
    r <- cor(te$handcount, te$pred)
    MSD <- mean((te$handcount - te$pred) ^ 2)
    cv[ii, ] <- c(r, MSD)
  }
  x <- matrix(c(mean(cv$r), mean(cv$MSD)), nrow = 1)
  return(as.data.frame(x))
}

prop_data <- seq(1, 1, by = 0.1)
prop_train <- seq(0.1, 0.9, by = 0.1)
n_thresh <- length(unique(M$lower_thresh))
n_prop <- length(prop_data)
n_out <- n_thresh * n_prop * length(prop_train)
r <- 0
MSD <- 0
reps <- 4000  # Reps at each proportion
iters <- 4000 # Iterations for each CV

CVs <- crossing(prop_data, prop_train, lower = unique(M$lower_thresh), r, MSD)

message(paste("\n", nrow(CVs), "combinations to check.\n"))

## Check number of cores
cl <- makeCluster(25)
registerDoParallel(cl)
for (ii in 1:nrow(CVs)) {
  tic()
  message(paste("Testing", CVs$prop_data[ii], CVs$prop_train[ii], CVs$lower[ii]))
  
  x <- foreach(jj = 1:reps, .combine = 'rbind') %dopar% {
    library(tidyverse)
    area_rarefaction(M, lower = CVs$lower[ii],
                     prop_data = CVs$prop_data[ii],
                     prop_train = CVs$prop_train[ii],
                     iters = iters)
  }
  CVs[ii, 4:5] <- colMeans(x)
  toc()
  message(paste(nrow(CVs) - ii), " remaining.")
  message("\n")
}
stopCluster(cl)

write_csv(CVs, path = file.path(rootDir, outfile))

#####

CVs <- read_csv(file.path(rootDir, outfile))

CVs$lower_f <- as.factor(CVs$lower)
CVs$prop_train_f <- as.factor(CVs$prop_train)

p1 <- CVs %>%
  ggplot(aes(prop_data, r)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  geom_point() +
  facet_grid(lower_f ~ prop_train_f)
p2 <- CVs %>%
  ggplot(aes(prop_data, MSD)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  geom_point() +
  facet_grid(lower_f ~ prop_train_f)
plot_grid(p1, p2)

p1
p2

CVs %>% 
  arrange(desc(r))

CVs %>% 
  arrange(MSD)

