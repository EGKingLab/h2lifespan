# Egg Count Estimation

This is the order in which files should be executed.

`get_image_dimensions.R`
- Loads each image file and outputs the maximum dimension. Each image is (roughly) square, so the maximum dimension is a good estimate.
- Reads: Image files from `hd_hand_counted_masked` and `h2_fec_images`
- Writes: `image_dimensions_hd_hand_counted_masked.csv` and `image_dimensions_h2_fec_images.csv`

`Area_Summation_optimization_image_processing.py`
- Estimates areas for the training set of images
- Reads:
    - Images in `hd_hand_counted_masked`
    - `hd_hand_counted.xlsx`: List of images with training handcounts
    - `bad_images.xlsx`: List of images that are not suitable for training
- Writes:
    - `area_summation_HC.csv`

`threshold_optimization_linear.R`
- Performs either coarse or fine (`coarse` flag) optimization on training images to find the threshold value that minimizes MSE between prediction and handcount using a linear model with square root of 'egg' area: `handcount ~ I(area^0.5) + img_size - 1`. Uses a variable percentage of the data (for rarefaction) and a variable train/test split.
- Reads:
    - `area_summation_HC.csv`: Areas calculated for all thresholds from 30 to 150
    - `hd_hand_counted.xlsx`: Excel file with handcounts
    - `image_dimensions_hd_hand_counted_masked.csv`: CSV file with maximum image dimensions
- Writes:
    - `threshold_optimization_linear_coarse.csv`
    - `threshold_optimization_linear_fine.csv`
- Analysis of the resulting coarse optimization are used to guide the fine optimization. Results of the fine optimization are used to determine the optimal threshold value to use for the full image set.

`Area_Summation_h2_fec_images.py`
- Processes the full set of images, calcaulting area for the optimal threshold value (set with `lower_threshes = [X]`).
- Reads:
    - Images in `h2_fec_images`
    - `feclife_with-image-ids.xlsx`: Excel file with information on image names and those that were manually handcounted (but not part of the training set).
- Writes:
    - `area_summation_linear_h2_fecimages.csv`
    - If `write_images = True` thresholded images are written to `h2_thresh_fecimages`

`h2_fec_prediction.Rmd`
- Predicts egg counts from image areas for the full set using the threshold value (`linear_threshold <- 46`) determined above. Training image data are loaded and used to create a linear model for predicting egg counts for the full set.
- Reads:
    - `hd_hand_counted.xlsx`: Excel file with hand counts for training images
    - `bad_images.xlsx`: Images that were handcouned but should not be part of the training set
    - `area_summation_HC.csv`: Areas for the training set
    - `image_dimensions_hd_hand_counted_masked.csv`: Maximum image dimensions for the training set
    - `handcount_new_bad_images.xlsx`: Additional handcounted images
