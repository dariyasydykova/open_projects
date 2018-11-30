# load packages needed to run this code
library(generativeart)
library(ggplot2)
library(tidyr)
library(dplyr)
library(gganimate)

# this function makes generative art 
make_frame <- function(seed = 4182, state = 1, formula) {
  # set seed
  set.seed(seed)

  # making a data frame with the visualization
  df <- seq(from = -pi, to = pi, by = 0.02) %>%
    expand.grid(x_i = ., y_i = .) %>%
    dplyr::mutate(!!!formula)

  # split up the data frame to extract the final state
  df %>% select(x, y) %>%
    mutate(state = state)
}

# set different formulas that will be used in the animation
my_formula1 <- list(
  x = quote(runif(1, -1, 1) * x_i^3 - sin(y_i^2)),
  y = quote(runif(1, -1, 1) * y_i^3 - cos(x_i^2))
)

my_formula2 <- list(
  x = quote(runif(1, -1, 1) * x_i^3 - sin(y_i^2)),
  y = quote(runif(1, -1, 1) * y_i^4 - cos(x_i^4))
)

my_formula3 <- list(
  x = quote(runif(1, -1, 1) * x_i^3 - sin(y_i^3)),
  y = quote(runif(1, -1, 1) * y_i^3 - cos(x_i^3))
)

# make generative art for different seeds
rbind(make_frame(4182, 2, my_formula1), make_frame(2096, 1, my_formula2), make_frame(9228, 3, my_formula3)) -> df_animate

# make a data frame for background colors
df_back <- data.frame(
  xmin = -1.3, ymin = -1.3, xmax = 1.3, ymax = 1.3, x = 0, y = 0,
  fill = c("#ffde7d", "#a8e6cf", "#defcf9"),
  state = c(1, 2, 3)
)

# make an animation
# we convert x and y from cartesian to polar coordinates
# we wanted to keep visualization in polar coordinates and we wanted the background to change colors using `gganimate`
# `gganimate` only works on geoms, so the background is drawn with geom_rect()
df_animate %>%
  group_by(state) %>%
  mutate(
    r = (y-min(y))/diff(range(y)), # convert x and y to polar coordinates
    theta = 2*pi*(x-min(x))/diff(range(x))
  ) %>%
  ggplot(ggplot2::aes(x = r*sin(theta), y = r*cos(theta))) +
  geom_rect(
    data = df_back,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill, group = 1, x = 1, y = 1),
    color = NA
  ) +
  scale_fill_identity() +
  geom_point(alpha = 0.2, size = 0, shape = 20) +
  theme_void() +
  coord_fixed(expand = FALSE) +
  transition_states(state, transition_length = 10, state_length = 0) -> p_genart

# animate
animate(p_genart, 
        device = "png",
        width = 600, 
        height = 600)

# save as gif
anim_save("generativeart.gif")
