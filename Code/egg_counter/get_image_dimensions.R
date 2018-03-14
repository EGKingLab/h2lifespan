library(tidyverse)
library(jpeg)

# Get list of images
base_path <- "../../../hd_hand_counted_masked/"
flist <- list.files(base_path, pattern = ".JPG")

out <- tibble(camera_id = character(length(flist)),
              img_size = numeric(length(flist)))

for (ii in 1:length(flist)) {
  img_path <- paste0(base_path, flist[ii])
  jpg <- readJPEG(img_path, native = TRUE)
  out[ii, "camera_id"] <- flist[ii]
  out[ii, "img_size"] <- max(dim(jpg)[2])
}

out
hist(out$img_size)

write_csv(out, path = "../../Data/Processed/image_dimensions.csv")
