library(tidyverse)
library(tfestimators)
library(readxl)

D <- read_csv("../../Data/Processed/area_summation_HC_30_80.csv",
              col_types = "cii") %>% 
  as.data.frame()

HC <- read_excel("../../Data/Processed/hd_hand_counted.xlsx") %>% 
  dplyr::select(camera_id, handcount)

D <- full_join(D, HC)

# return an input_fn for a given subset of data
D_input_fn <- function(data, num_epochs = 1) {
  input_fn(data, 
           features = c("lower_thresh", "area"), 
           response = "handcount",
           batch_size = 32,
           num_epochs = num_epochs)
}

cols <- feature_columns( 
  column_numeric("lower_thresh", "area")
)

model <- linear_regressor(feature_columns = cols)

indices <- sample(1:nrow(D), size = 0.80 * nrow(D))
train <- D[indices, ]
test  <- D[-indices, ]

# train the model
model %>% train(D_input_fn(train, num_epochs = 50))
model %>% evaluate(D_input_fn(test))

(newdata <- D[1:3, ])
model %>% predict(D_input_fn(newdata))
