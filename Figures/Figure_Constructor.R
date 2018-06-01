library(tidyverse)
library(cowplot)
library(survival)
library(survminer)

# Figure 3
load("KM_plot.Rda")
load("Fec_line_plot.Rda")
load(file="ttrait_plot.rda")

top_row <- plot_grid(KM_plot, ttrait, labels = c('a.', 'c.'), align = 'h',
                     label_size = 10)
P<-plot_grid(top_row, Fec_line_plot, labels = c('', 'b.'), 
                   ncol = 1,hjust=0, label_size = 10)


#P <- plot_grid(KM_plot, ttrait,Fec_line_plot, nrow = 1, ncol = 2,
#               labels = c("a.", "b.","c."),
#               label_size = 10)
P
ggsave(filename = "Figure_3.png", plot = P, width = 6.9, height = 6.9)

# Figure 4
load("Lifespan_GxE.Rda")
load("Fecundity_GxE.Rda")
load("Lifespan_h2.Rda")
load("Lifespan_correlation.Rda")

P <- plot_grid(Lifespan_GxE, Fecundity_GxE, 
               Lifespan_h2, Lifespan_correlation,
               nrow = 2, ncol = 2,
               labels = c("a.", "b.", "c.", "d."),
               label_size = 10)
P
ggsave(filename = "Figure_4.png", plot = P, width = 6.9, height = 6.9)
