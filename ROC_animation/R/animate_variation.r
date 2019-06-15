# load packages needed to run this code
library(tidyverse)
library(cowplot)
library(gganimate)
library(magick)
library(here)
library(yardstick)

# set the second level of truth to positive in yardstick
options(yardstick.event_first = FALSE)

# set up a variable for a base directory
# this ensure files get written to correct directories
base_dir <- here()

# set seed to reproduce the given results
set.seed(5678)

# simulate predictor values for 2 different outcomes
# predictors will be normally distributed
# two classes are balanced at time 1
distr_data <- data.frame()
for (i in c(1:7)) {
  outcome1 <- data.frame(predictor = rnorm(100, mean = -5, sd = 5), outcome = 1, time = i)
  outcome2 <- data.frame(predictor = rnorm(100, mean = 5, sd = 5), outcome = 2, time = i)
  distr_data <- rbind(distr_data, outcome1, outcome2)
}

distr_data <- 
  distr_data %>% 
  group_by(time, outcome) %>% 
  mutate(mean_predictor = mean(predictor)) 

# make an animation with distributions of linear predictors
p_dist <- ggplot(distr_data) +
  geom_density(aes(x = predictor, fill = factor(outcome), stat(count)), alpha = 0.7, color = NA) +
  geom_hline(yintercept = 0, color = "black", size = 0.5, linetype = 2) +
  geom_vline(aes(xintercept = mean_predictor, color = factor(outcome))) + 
  scale_x_continuous(limits = c(-30, 30)) +
  scale_fill_manual(values = c("#C04A56", "#3D8CF1")) +
  scale_color_manual(values = c("#C04A56", "#3D8CF1")) +
  transition_states(time, transition_length = 1, state_length = 1) +
  ggtitle(" ") + # adding an emtpy title to align y axis with ROC plot
  theme_cowplot() +
  theme(legend.position = "none")

# calculate ROC curves and AUC values
ROC_data <- 
  distr_data %>%
  group_by(time) %>%
  roc_curve(
    truth = factor(outcome), 
    predictor, 
    options = list(transpose = FALSE)
  ) %>% 
  mutate(true_pos_rate = sensitivity, false_pos_rate = 1 - specificity) %>% 
  arrange(false_pos_rate, true_pos_rate)

AUC_data <- 
  distr_data %>%
  group_by(time) %>%
  roc_auc(truth = factor(outcome), predictor) %>% 
  mutate(AUC_rounded = round(.estimate, 3))

ROC_anim_data <- 
  ROC_data %>% 
  left_join(AUC_data, by = "time") 

# calculate ROC curves and AUC values
PR_data <- 
  distr_data %>%
  group_by(time) %>%
  pr_curve(truth = factor(outcome), predictor) # calculate TP rate and FP rate for every possible cutoff
  
# reverse factor in `AUC` variable so the AUC values match to the timing of the animation
ROC_anim_data$.estimate <- fct_inorder(factor(ROC_anim_data$.estimate))

# make an animation with ROC curves
p_ROC <- ggplot(data = ROC_anim_data, aes(x = false_pos_rate, y = true_pos_rate)) +
  geom_line(size = 1) +
  geom_abline(intercept = 0, slope = 1) +
  transition_states(AUC_rounded, transition_length = 1, state_length = 1) +
  labs(title = "AUC = {closest_state}") +
  scale_x_continuous(name = "false positive rate") +
  scale_y_continuous(name = "true positive rate") +
  theme_cowplot()

# make an animation with precision-recall curves
p_PR <- ggplot(data = PR_data, aes(x = recall, y = precision)) +
  geom_line(size = 1) +
  transition_states(time, transition_length = 1, state_length = 1) +
  scale_x_continuous(limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1)) +
  ggtitle(" ") + # adding an emtpy title to align y axis with ROC plot
  theme_cowplot()

# save each animation as individual frames
# each frame will be saved as a PNG image
p_dist_gif <- animate(p_dist,
                      device = "png",
                      width = 400,
                      height = 400,
                      renderer = file_renderer(paste(base_dir, "/animations/gganim_variation_n100", sep = ""), prefix = "p_dist", overwrite = TRUE)
)

p_ROC_gif <- animate(p_ROC,
                     device = "png",
                     width = 400,
                     height = 400,
                     renderer = file_renderer(paste(base_dir, "/animations/gganim_variation_n100", sep = ""), prefix = "p_ROC", overwrite = TRUE)
)
p_PR_gif <- animate(p_PR,
                    device = "png",
                    width = 400,
                    height = 400,
                    renderer = file_renderer(paste(base_dir, "/animations/gganim_variation_n100", sep = ""), prefix = "p_PR", overwrite = TRUE)
)

# stitch animations together
# read the first image (frame) of each animation
a <- image_read(p_dist_gif[[1]])
b <- image_read(p_ROC_gif[[1]])
c <- image_read(p_PR_gif[[1]])
# combine the two images into a single image
combined <- image_append(c(a, b, c))
new_gif <- c(combined)
for (i in 2:100) { # combine images frame by frame
  a <- image_read(p_dist_gif[[i]])
  b <- image_read(p_ROC_gif[[i]])
  c <- image_read(p_PR_gif[[i]])
  combined <- image_append(c(a, b, c))
  new_gif <- c(new_gif, combined)
}

# make an animation of the combined images
combined_gif <- image_animate(new_gif)
# save as gif
image_write(combined_gif, paste(base_dir, "/animations/variation_n100.gif", sep = ""))
