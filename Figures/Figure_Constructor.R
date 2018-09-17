library(tidyverse)
library(cowplot)
library(survival)
library(survminer)

source("../Code/heritability/color_map.R")
source("../Code/heritability/ggplot_theme.R")


# Figure 2
load("KM_plot.Rda")
load("Fec_line_plot.Rda")
load("ttrait_plot.rda")

bottom_row <- plot_grid(KM_plot, ttrait, labels = c('b.', 'c.'),
                        align = 'h',
                        label_size = 10)
P <- plot_grid(Fec_line_plot, bottom_row, labels = c('a.', ''), 
               ncol = 1, hjust = 0, label_size = 10)

P
ggsave(filename = "Figure_2.png", plot = P, width = 6.9, height = 6.9)
ggsave(filename = "Figure_2.tiff", plot = P, width = 6.9, height = 6.9, dpi = 300)

# Figure 3
load("Lifespan_GxE.Rda")
load("Fecundity_GxE.Rda")
load("Lifespan_h2.Rda")
load("Lifespan_correlation.Rda")

P <- plot_grid(Lifespan_h2, Lifespan_correlation,
               Lifespan_GxE, Fecundity_GxE, 
               nrow = 2, ncol = 2,
               labels = c("a.", "b.", "c.", "d."),
               label_size = 10)
P
ggsave(filename = "Figure_3.png", plot = P, width = 6.9, height = 6.9)
ggsave(filename = "Figure_3.tiff", plot = P, width = 6.9, height = 6.9, dpi = 300)

# Figure S2
load("Fecundity_total_fec_h2.Rda")
load("Fecundity_correlation.Rda")

P <- plot_grid(Fecundity_h2, Fecundity_correlation,
               ncol = 2, labels = c("a.", "b."),
               label_size = 10)
P
ggsave(filename = "Figure_SI2.png", plot = P, width = 6.9, height = 3.5)
ggsave(filename = "Figure_SI2.tiff", plot = P, width = 6.9, height = 3.5, dpi = 300)
