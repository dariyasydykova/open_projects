# load packages needed to run this code
library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(gganimate)
library(magick)

# this function calculates true positive rate and false positive rate to make an ROC curve
calc_ROC <- function(probabilities, known_truth, model.name = NULL)
{
  outcome <- as.numeric(factor(known_truth))-1
  pos <- sum(outcome) # total known positives
  neg <- sum(1-outcome) # total known negatives
  pos_probs <- outcome*probabilities # probabilities for known positives
  neg_probs <- (1-outcome)*probabilities # probabilities for known negatives
  true_pos <- sapply(probabilities,
                     function(x) sum(pos_probs>= x)/pos) # true pos. rate
  false_pos <- sapply(probabilities,
                      function(x) sum(neg_probs>= x)/neg)
  if (is.null(model.name))
    result <- data.frame(true_pos, false_pos)
  else
    result <- data.frame(true_pos, false_pos, model.name)
  
  result %>% add_row(true_pos = 0, false_pos = 0) %>% arrange(false_pos, true_pos)
}

# make a reduced iris data set that only contains virginica and versicolor species
iris.small <- filter(iris, Species %in% c("virginica", "versicolor"))

# fit a logistic regression model to the data
glm.out <- glm(Species ~ Petal.Width + Petal.Length + Sepal.Width,
               data = iris.small,
               family = binomial)

# make a data frame with linear predictors from the model and true species assignment
lr_data <- data.frame(predictor = glm.out$linear.predictors, 
                      Species = iris.small$Species)

# get a density plot for each species
d_virg <- density(filter(lr_data, Species == "virginica")$predictor)
d_vers <- density(filter(lr_data, Species == "versicolor")$predictor)

# move each species' density plot to overlap at the center.
# this is the starting point
virg_t1 <- data.frame(predictor = d_virg$x - 6.7, density = d_virg$y, time = 1, Species = "virginica")
vers_t1 <- data.frame(predictor = d_vers$x + 6.8, density = d_vers$y, time = 1, Species = "versicolor")

virg_t2 <- virg_t1 %>% mutate(predictor = predictor*0.3, time = 2) 
vers_t2 <- vers_t1 %>% mutate(time = 2)

rbind(virg_t1, virg_t2) -> virg_data
rbind(vers_t1, vers_t2) -> vers_data

# make an animation with distributions of linear predictors
p_dist <- ggplot(mapping = aes(predictor, density, group = 1)) +
  geom_hline(yintercept = 0, color = "black", size = 0.5, linetype = 2) +
  geom_area(data = vers_data, alpha = 0.7, fill = "#C04A56") +
  geom_area(data = virg_data, alpha = 0.7, fill = "#3D8CF1") +
  scale_x_continuous(limits = c(-45, 50)) +
  transition_states(time, transition_length = 1, state_length = 1) +
  ggtitle(" ") + # adding an emtpy title to align y axis with ROC plot
  theme_cowplot()

# create a new data frame with linear predictors, species, and time
virg_t1 <- lr_data %>% filter(Species == "virginica") %>% mutate(predictor = predictor - 6.7, time = 1)
vers_t1 <- lr_data %>% filter(Species == "versicolor") %>% mutate(predictor = predictor + 6.8, time = 1)

# change predictor values and add `time` variable to respresent a state in an animation
# for each time point, changes in predictor values should match to the predictor values of the density plot
virg_t1 %>% mutate(predictor = mean(predictor) + 0.3*(predictor - mean(predictor)), time = 2) -> virg_t2
vers_t1 %>% mutate(time = 2) -> vers_t2

# combine all data frames and calculate ROC curves and AUC values
rbind(virg_t1, virg_t2, vers_t1, vers_t2) %>% # combine all data frames together
  mutate(probabilities = exp(predictor)/(1+exp(predictor))) %>% # calculate probabilities for linear predictors
  group_by(time) %>% 
  do(results = calc_ROC(probabilities = .$probabilities, # calculate TP rate and FP rate for every possible cutoff
                        known_truth = .$Species)) %>%
  group_by(time) %>%
  do(as.data.frame(.$results)) %>% # store output from calc_ROC() in the data frame
  mutate(delta = false_pos - lag(false_pos)) %>%# calculate AUC values
  mutate(AUC = sprintf("%.3f", sum(delta*true_pos, na.rm = T))) -> ROC

# make an animation with ROC curves
p_ROC <- ggplot(data = ROC, aes(x = false_pos, y = true_pos)) +
  geom_line(size = 1) +
  geom_abline(intercept = 0, slope = 1) +
  transition_states(AUC, transition_length = 1, state_length = 1) +
  ggtitle("AUC = {closest_state}") +
  scale_x_continuous(name = "false positive rate") +
  scale_y_continuous(name = "true positive rate") +
  theme_cowplot()

# save each animation as individual frames
# each frame will be saved as a PNG image
p_dist_gif <- animate(p_dist, 
                      device = "png",
                      width = 400, 
                      height = 400, 
                      renderer = file_renderer("./gganim_SD", prefix = "p_dist", overwrite = TRUE))
p_ROC_gif <- animate(p_ROC, 
                     device = "png",
                     width = 400, 
                     height = 400,
                     renderer = file_renderer("./gganim_SD", prefix = "p_ROC", overwrite = TRUE))

# stitch two animations together
# read the first image (frame) of each animation
a <- image_read(p_dist_gif[[1]])
b <- image_read(p_ROC_gif[[1]])
# combine the two images into a single image
combined <- image_append(c(a, b))
new_gif <- c(combined)
for(i in 2:100){ # combine images frame by frame
  a <- image_read(p_dist_gif[[i]])
  b <- image_read(p_ROC_gif[[i]])
  combined <- image_append(c(a, b))
  new_gif <- c(new_gif, combined)
}

# make an animation of the combined images
combined_gif <- image_animate(new_gif)
# save as gif
image_write(combined_gif, "SD.gif")
