library(tidyverse)
library(cowplot)
library(magick)
library(grid)

load("egg_count_area.Rda")

raw <- rasterGrob(image_read("IMG_2644.JPG"), interpolate = TRUE)
thresh <- rasterGrob(image_read("IMG_2644_thresh_53.JPG"), interpolate = TRUE)
p1

P <- plot_grid(plot_grid(raw, thresh, ncol = 2, labels = c("a.", "b."),
                         label_size = 10),
               p1, nrow = 2,
               labels = c("", "c."),
               label_size = 10)

ggsave(filename = "../Figure_2.png", plot = P, width = 87 / 25.4, height = 5)
