# load packages needed to run this code
library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(gganimate)

# make a data frame for a tree
tree_df <- data.frame(time = c(0, 5, 0, 5, 3, 5, 3, 5),
                      position = c(5, 10, 5, 0, 8, 6, 2, 4),
                      branch = c('b1', 'b1', 'b2', 'b2', 'b3', 'b3', 'b4', 'b4'),
                      sequence = c("EPNGENRR…",
                                   "EPNGENRR…",
                                   "KPNGESDK…",
                                   "KPNGESDK…",
                                   "DPHGESFF…",
                                   "DPHGESFF…",
                                   "IPHGENRR…",
                                   "IPHGENRR…"))

# seq_df <- data.frame(time = 5,
#                      position = c(0, 4, 6, 10),
#                      sequence = c("EPNGENRR…",
#                                   "KPNGESDK…",
#                                   "DPHGESFF…",
#                                   "IPHGENRR…"))

# subs_df <- data.frame(time = c(1, 2.5, 2, 2.5, 4, 4.5),
#                       position = c(6, 7.5, 3, 2.5, 1, 9.5),
#                       type = c(1:6))

ancestor_seq <- "DPHGESFF…"

ggplot(tree_df, aes(x = time, y = position, group = branch)) + 
  geom_path(size = 1) +
  scale_y_continuous(limits = c(0,10), breaks = c(1:10)) +
  scale_x_continuous(limits = c(0,10), breaks = c(1:10)) +
  background_grid(major = "xy") 

ggplot(data = tree_df, mapping = aes(x = time, y = position)) + 
  geom_line(aes(group = branch), size = 1.5) + 
  #geom_segment(aes(xend = time, yend = position), linetype = 2, colour = 'grey') + 
  geom_point(size = 3) +
  geom_text(aes(label = sequence), 
            hjust = 0, 
            nudge_x = 0.2,
            size = 6,
            family = "Courier") + 
  geom_text(aes(x = 0, y = 5, label = ancestor_seq), 
            hjust = 1,
            nudge_x = -0.2,
            size = 6,
            family = "Courier") + 
  transition_reveal(branch, time) + 
  coord_cartesian(clip = 'off') + 
  theme(axis.line = element_blank(), # remove axes, axes labels, and background from the plot
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none",
        plot.background = element_blank(),
        plot.margin = margin(5.5, 100, 5.5, 100))

