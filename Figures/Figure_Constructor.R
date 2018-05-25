library(tidyverse)
library(cowplot)

# Figure 3
load("KM_plot.Rda")
load("Fec_line_plot.Rda")

P <- plot_grid(KM_plot, Fec_line_plot, nrow = 1, ncol = 2,
               labels = c("a.", "b."),
               label_size = 10)
P
ggsave(filename = "Figure_3.png", plot = P, width = 6.9, height = 3)

# Figure 4
load("Lifespan_GxE.Rda")
load("Fecundity_GxE.Rda")

P <- plot_grid(Lifespan_GxE, Fecundity_GxE, nrow = 2, ncol = 2,
               labels = c("a.", "b.", "c.", "d"),
               label_size = 10)
P
ggsave(filename = "Figure_4.png", plot = P, width = 6.9, height = 6.9)
