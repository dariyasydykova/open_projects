# load packages needed to run this code
library(generativeart)
library(ggplot2)
library(tidyr)
library(dplyr)
library(gganimate)

# set different formulas that will be used in the animation
set.seed(6288)

# include a specific formula, for example:
my_formula <- list(
  x = quote(runif(1, -1, 1) * x_i^2 - sin(y_i^2)),
  y = quote(runif(1, -1, 1) * y_i^2 - cos(x_i^2))
)

# making a data frame with the visualization
df <- generate_data(my_formula)

# make different states 
df %>% select(x, y) %>%
  mutate(state = 1) -> df_t1



# make a file name
file_name <- generate_filename(seed)

# make an animation
df_animate %>%
  group_by(state) %>%
  ggplot(ggplot2::aes(x = x, y = y)) +
  scale_fill_identity() +
  geom_point(alpha = 0.2, size = 0, shape = 20) +
  theme_void() +
  coord_fixed(expand = FALSE) +
  transition_states(state, transition_length = 5, state_length = 0) -> p_genart

# animate
animate(p_genart, 
        device = "png",
        width = 600, 
        height = 600)

# save as gif
anim_save("generativeart.gif")
