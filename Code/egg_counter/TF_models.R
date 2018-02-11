library(tidyverse)
library(keras)
library(readxl)
library(caret)

set.seed(832764)

D <- read_csv("../../Data/Processed/area_summation_HC_30_80.csv",
              col_types = "cii") %>% 
  as.data.frame()

HC <- read_excel("../../Data/Processed/hd_hand_counted.xlsx") %>% 
  dplyr::select(camera_id, handcount)

D <- full_join(D, HC) %>% 
  filter(lower_thresh == 46)

trainIndex <- createDataPartition(D$handcount, 
                                  p = 0.8, 
                                  list = TRUE, 
                                  times = 1)

dtrain <- D[trainIndex[['Resample1']], ]
dtest <- D[-trainIndex[['Resample1']], ]

# Function to build model

build_model <- function() {
  model <- keras_model_sequential() %>% 
    layer_dense(units = 64, activation = "relu", 
                input_shape = dim(train_data)[[2]]) %>% 
    layer_dense(units = 64, activation = "relu") %>% 
    layer_dense(units = 1) 
  
  model %>% compile(
    optimizer = "rmsprop", 
    loss = "mse", 
    metrics = c("mae")
  )
}
