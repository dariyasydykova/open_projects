# load packages needed to run this code
library(generativeart)
library(ggplot2)
library(tidyr)
library(dplyr)
library(gganimate)

# set seed
set.seed(4182)

# formula for new x, y coordinates
formula <- list(
  x = quote(runif(1, -1, 1) * x_i^3 - sin(y_i^2)),
  y = quote(runif(1, -1, 1) * y_i^3 - cos(x_i^2))
)

# making a data frame with the visualization
for (i in c(1:5)){ # going through five iterations to get to the desired image
  df <- seq(from = -pi, to = pi, by = 0.02) %>%
    expand.grid(x_i = ., y_i = .) %>%
    dplyr::mutate(!!!formula)
}

# split up the data frame to extract the initial and final states
df %>% select(x = x_i, y = y_i) %>%
  mutate(state = 1) -> df_t1 #initial state
df %>% select(x, y) %>%
  mutate(state = 2) -> df_t2 #final state

# combine the two data frames together
rbind(df_t1, df_t2) -> df_animate

# make an animation
df_animate %>%
  ggplot(aes(x = x, y = y)) +
  geom_point(alpha = 0.1, size = 0, shape = 20) +
  theme_void() +
  coord_fixed() +
  coord_polar() +
  theme(plot.background = element_rect(fill = "#ffe79a")) +
  transition_states(state, transition_length = 1, state_length = 1) -> p_genart

# save each animation as individual frames
# each frame will be saved as a PNG image
animate(p_genart, 
        device = "png",
        width = 600, 
        height = 600)

# save as gif
anim_save("image_generation.gif")
