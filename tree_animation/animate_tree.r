# load packages needed to run this code
library(tidyverse)
library(cowplot)
library(gganimate)

# make a data frame for a tree
tree_df <- data.frame(
  x = c(0, 3, 0, 3, 3, 5, 3, 5, 3, 5, 3, 5),
  y = c(5, 8, 5, 2, 8, 10, 8, 6, 2, 0, 2, 4),
  branch = c("b1", "b1", "b2", "b2", "b3", "b3", "b4", "b4", "b5", "b5", "b6", "b6"),
  sequence = c(
    "DP GESFF…",
    "DP GESFF…",
    "DPNGESFF…",
    "EPNGESFF…",
    "KPNGESDK…",
    "KPNGESDK…",
    "DPHGESFF…",
    "DPHGESFF…",
    "IPHGENRR…",
    "IPHGENRR…",
    "IPHGENRR…",
    "IPHGENRR…"
  ),
  subs = c(
    "  H     ",
    "  N     ",
    "DPNGESFF…",
    "EPNGESFF…",
    "KPNGESDK…",
    "KPNGESDK…",
    "DPHGESFF…",
    "DPHGESFF…",
    "IPHGENRR…",
    "IPHGENRR…",
    "IPHGENRR…",
    "IPHGENRR…"
  ),
  type = c(
    "#5893d4",
    "#f7aa00",
    "black",
    "black",
    "black",
    "black",
    "black",
    "black",
    "black",
    "black",
    "black",
    "black"
  )
)

subs_df <- data.frame(
  time = c(1, 2.5, 2, 2.5, 4, 4.5),
  position = c(6, 7.5, 3, 2.5, 1, 9.5),
  type = c(1:6)
)

ancestor_seq <- "DPHGESFF…"

ggplot(tree_df, aes(x = x, y = y, group = branch)) +
  geom_path(size = 1) +
  scale_y_continuous(limits = c(0, 10), breaks = c(1:10)) +
  scale_x_continuous(limits = c(0, 10), breaks = c(1:10)) +
  background_grid(major = "xy") +
  geom_text(aes(label = branch))

ggplot(data = tree_df, mapping = aes(x = x, y = y)) +
  geom_line(aes(group = branch), size = 1.5) +
  # geom_segment(aes(xend = time, yend = position), linetype = 2, colour = 'grey') +
  # geom_point(aes(color = sequence), size = 3) +
  geom_text(aes(label = sequence),
    hjust = 0,
    nudge_x = 0.2,
    size = 6,
    family = "Courier",
    color = "black"
  ) +
  geom_text(aes(label = subs, color = type),
    hjust = 0,
    nudge_x = 0.2,
    size = 6,
    family = "Courier"
  ) +
  geom_text(
    x = 0, y = 5,
    label = ancestor_seq,
    hjust = 1,
    nudge_x = -0.4,
    size = 6,
    family = "Courier"
  ) +
  transition_reveal(x) +
  coord_cartesian(clip = "off", xlim = c(-2, 7)) +
  scale_color_discrete(guide = "none") +
  theme_void()
