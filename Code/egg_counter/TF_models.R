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

train_data <- as.matrix(D[trainIndex[['Resample1']], "area"])
train_targets <- as.array(D[trainIndex[['Resample1']], "handcount"])
test_data <- D[-trainIndex[['Resample1']], "area"]
test_targets <- as.array(D[-trainIndex[['Resample1']], "handcount"])

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

k <- 4
indices <- sample(1:nrow(train_data))
folds <- cut(indices, breaks = k, labels = FALSE)

num_epochs <- 100
all_scores <- c()
for (i in 1:k) {
  cat("processing fold #", i, "\n")
  # Prepare the validation data: data from partition # k
  val_indices <- which(folds == i, arr.ind = TRUE) 
  val_data <- train_data[val_indices, ]
  val_targets <- train_targets[val_indices]
  
  # Prepare the training data: data from all other partitions
  partial_train_data <- train_data[-val_indices,]
  partial_train_targets <- train_targets[-val_indices]
  
  # Build the Keras model (already compiled)
  model <- build_model()
  
  # Train the model (in silent mode, verbose=0)
  model %>% fit(partial_train_data, partial_train_targets,
                epochs = num_epochs, batch_size = 1, verbose = 1)
  
  # Evaluate the model on the validation data
  results <- model %>% evaluate(val_data, val_targets, verbose = 1)
  all_scores <- c(all_scores, results$mean_absolute_error)
}  

mean(all_scores)

k_clear_session()

num_epochs <- 500
all_mae_histories <- NULL
for (i in 1:k) {
  cat("processing fold #", i, "\n")
  
  # Prepare the validation data: data from partition # k
  val_indices <- which(folds == i, arr.ind = TRUE)
  val_data <- train_data[val_indices,]
  val_targets <- train_targets[val_indices]
  
  # Prepare the training data: data from all other partitions
  partial_train_data <- train_data[-val_indices,]
  partial_train_targets <- train_targets[-val_indices]
  
  # Build the Keras model (already compiled)
  model <- build_model()
  
  # Train the model (in silent mode, verbose=0)
  history <- model %>% fit(
    partial_train_data, partial_train_targets,
    validation_data = list(val_data, val_targets),
    epochs = num_epochs, batch_size = 1, verbose = 1
  )
  mae_history <- history$metrics$val_mean_absolute_error
  all_mae_histories <- rbind(all_mae_histories, mae_history)
}

average_mae_history <- data.frame(
  epoch = seq(1:ncol(all_mae_histories)),
  validation_mae = apply(all_mae_histories, 2, mean)
)

ggplot(average_mae_history, aes(x = epoch, y = validation_mae)) + 
  geom_line()

ggplot(average_mae_history, aes(x = epoch, y = validation_mae)) + 
  geom_smooth()

# Get a fresh, compiled model.
model <- build_model()

# Train it on the entirety of the data.
model %>% fit(train_data, train_targets,
              epochs = 150, batch_size = 16, verbose = 0)

result <- model %>% evaluate(test_data, test_targets)

result

preds <- model %>% predict(test_data)
cor(preds, test_targets)

# Load new data
suppressWarnings(
  M <- read_excel("../../Data/Processed/feclife_with-image-ids.xlsx")
)

# Load areas
h2_fec_areas <- read_csv("../../Data/Processed/area_summation_linear_h2_fecimages.csv",
                         col_types = "cii") %>% 
  filter(lower_thresh == 46)

M <- left_join(M, h2_fec_areas) %>% 
  rename(area_linear = area) %>% 
  drop_na(area_linear)

M$predicted_count_tf <- model %>% predict(M$area_linear)
ggplot(M, aes(predicted_count_tf)) +
  geom_histogram(bins = 30)
