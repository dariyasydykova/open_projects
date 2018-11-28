# load packages needed to run this code
library(generativeart)
library(ggplot2)
library(tidyr)
library(dplyr)
library(gganimate)
library(magick)

# set seed
set.seed(4182)

# include a specific formula, for example:
my_formula <- list(
  x = quote(runif(1, -1, 1) * x_i^3 - sin(y_i^2)),
  y = quote(runif(1, -1, 1) * y_i^3 - cos(x_i^2))
)

# making a data frame with the visualization
for (i in c(1:5)) { # iterating to get to the image I want
  df <- seq(from = -pi, to = pi, by = 0.02) %>%
    expand.grid(x_i = ., y_i = .) %>%
    dplyr::mutate(!!!my_formula)
}

# split up the data frame to make the beginning state and the final state
df %>% select(x = x_i, y = y_i) %>%
  mutate(state = 1) -> df_t1
df %>% select(x, y) %>%
  mutate(state = 2) -> df_t2
# combine 
rbind(df_t1, df_t2) -> df_animate

# make an animation
df_animate %>%
  ggplot2::ggplot(ggplot2::aes(x = x, y = y)) +
  ggplot2::geom_point(alpha = 0.3, size = 0, shape = 20) +
  ggplot2::theme_void() +
  ggplot2::coord_fixed() +
  ggplot2::coord_polar() +
  theme(plot.background = element_rect(fill = "#ffba5a")) +
  transition_states(state, transition_length = 1, state_length = 1) -> p_genart

# save each animation as individual frames
# each frame will be saved as a PNG image
p_genart_gif <- animate(p_genart, 
                     device = "png",
                     width = 600, 
                     height = 600,
                     renderer = file_renderer("./gganim", prefix = "p_genart", overwrite = TRUE))


# read the first image (frame) of the animation
a <- image_read(p_genart_gif[[1]])
new_gif <- c(a)
for(i in 2:100){ # combine images frame by frame
  a <- image_read(p_genart_gif[[i]])
  new_gif <- c(new_gif, a)
}

# make an animation of the combined images
ga_gif <- image_animate(new_gif)
# save as gif
image_write(ga_gif, "generativeart.gif")
