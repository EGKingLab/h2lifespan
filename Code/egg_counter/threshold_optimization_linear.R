# devtools::install_github("dgrtwo/broom")
library(doParallel)
library(tictoc)

library(tidyverse)
library(readxl)
library(cowplot)
library(broom)
library(forcats)
library(ggrepel)

coarse <- FALSE

if (coarse) {
  outfile <- "../../Data/Processed/threshold_optimization_linear_coarse.csv"
  infile <- "../../Data/Processed/area_summation_linear_coarse.csv"
  reps <- 1000  # Reps at each proportion
  iters <- 1000 # Iterations for each CV
  # prop_data <- seq(0.4, 1.0, by = 0.1)
  prop_data <- 1
  prop_train <- seq(0.1, 0.9, by = 0.1)
} else {
  outfile <- "../../Data/Processed/threshold_optimization_linear_fine.csv"
  infile <- "../../Data/Processed/area_summation_linear_fine.csv"
  reps <- 1000  # Reps at each proportion
  iters <- 1000 # Iterations for each CV
  prop_data <- 1
  prop_train <- seq(0.5, 0.9, by = 0.1)
}

# areas estimated from thresholding
areas <- read_csv(infile, col_types = "cii")

# handcounts
actual <- suppressWarnings(
  read_excel("../../Data/Processed/hd_hand_counted.xlsx") %>% 
  dplyr::select(camera_id, handcount) %>% 
  mutate(handcount = as.integer(handcount))
)

M <- full_join(areas, actual, by = "camera_id") %>% 
  drop_na(handcount) %>% 
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
  
  for (jj in 1:iters) {
    # Create list of rows for train/test
    samps <- sample(1:nrow(M_sub), trunc(prop_train * nrow(M_sub)))
    
    # Subset rows into train/test
    # For some reason 0 was getting changed to -Inf, fix that
    tr <- M_sub[samps, ]
    tr$handcount[is.infinite(tr$handcount)] <- 0
    te <- M_sub[-samps, ]
    te$handcount[is.infinite(te$handcount)] <- 0
    
    # Fit model on training set
    fm <- lm(handcount ~ area, tr)
    te$pred <- predict(fm, te)
    r <- cor(te$handcount, te$pred)
    MSD <- mean((te$handcount - te$pred) ^ 2)
    cv[jj, ] <- c(r, MSD)
  }
  x <- matrix(c(mean(cv$r), mean(cv$MSD)), nrow = 1)
  return(as.data.frame(x))
}

n_thresh <- length(unique(M$lower_thresh))
n_prop <- length(prop_data)
n_out <- n_thresh * n_prop * length(prop_train)
r <- 0
MSD <- 0

CVs <- crossing(prop_data, prop_train, lower = unique(M$lower_thresh), r, MSD)

message(paste("\n", nrow(CVs), "combinations to check.\n"))

## Check number of cores
cl <- makeCluster(20)
registerDoParallel(cl)
for (ii in 1:nrow(CVs)) {
  tic()
  message(paste("Testing",
                CVs$prop_data[ii],
                CVs$prop_train[ii],
                CVs$lower[ii]))
  
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

write_csv(CVs, path = outfile)

## Post-processing #####################################################

CVs <- read_csv(outfile) %>% 
  drop_na(r)

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
# plot_grid(p1, p2)

p1
p2

CVs %>% 
  arrange(desc(r))

CVs %>% 
  arrange(MSD)

