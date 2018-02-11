library(xgboost)
library(tidyverse)
library(readxl)
library(caret)

set.seed(3456)

D <- read_csv("../../Data/Processed/area_summation_HC_30_80.csv",
              col_types = "cii") %>%
  as.data.frame()

HC <- read_excel("../../Data/Processed/hd_hand_counted.xlsx") %>%
  dplyr::select(camera_id, handcount)

D <- full_join(D, HC) %>%
  filter(lower_thresh == 46)

trainIndex <- createDataPartition(D$area, p = 0.8,
                                  list = FALSE,
                                  times = 1)
head(trainIndex)

DTrain <- D[ trainIndex,]
DTest  <- D[-trainIndex,]

dtrain <- xgb.DMatrix(data = as.matrix(DTrain[, 2:4]),
                      label = DTrain$handcount,
                      missing = NA)
dtest <- xgb.DMatrix(data = as.matrix(DTest[, 2:4]),
                     missing = NA)

foldsCV <- createFolds(DTrain$handcount,
                       k = 7,
                       list = TRUE,
                       returnTrain = FALSE)

param <- list(booster = "gblinear",
              objective = "reg:linear",
              subsample = 0.7,
              max_depth = 5,
              colsample_bytree = 0.7,
              eta = 0.1,
              eval_metric = 'mae',
              base_score = 0.012, #average
              min_child_weight = 100)

# Perform xgboost cross-validation
xgb_cv <- xgb.cv(data = dtrain,
                 params = param,
                 nrounds = 200,
                 prediction = TRUE,
                 maximize = FALSE,
                 folds = foldsCV,
                 early_stopping_rounds = 30,
                 print_every_n = 5,
                 nthread = 20)

# Check best results and get best nrounds
print(xgb_cv$evaluation_log[which.min(xgb_cv$evaluation_log$test_mae_mean)])
nrounds <- xgb_cv$best_iteration

xgb <- xgb.train(params = param,
                 data = dtrain,
                 nrounds = nrounds,
                 verbose = 1,
                 print_every_n = 5)

# Predict
preds <- predict(xgb, dtest)

cor(DTest[, 'handcount'], preds)
