# load packages needed to run this code
library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(gganimate)
library(magick)

# make an animation with ROC curves
p_ROC <- ggplot(data = ROC, aes(x = false_pos, y = true_pos)) +
  geom_line(size = 1) +
  geom_abline(intercept = 0, slope = 1) +
  transition_states(AUC, transition_length = 1, state_length = 1) +
  ggtitle("AUC = {closest_state}") +
  scale_x_continuous(name = "false positive rate") +
  scale_y_continuous(name = "true positive rate") +
  theme_cowplot()