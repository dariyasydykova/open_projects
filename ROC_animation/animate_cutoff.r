# load packages needed to run this code
library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(gganimate)
library(magick)
library(mgcv)

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

sine_movement <- function(){
  df <- data.frame(frame = c(0, 20, 30, 45, 60, 80, 90, 100, 110, 120, 130),
                   line_position = c(-35, 0, 10, 5, -5, 25, 42, 25, 5, -25, -45))
  
  fit <- gam(line_position ~ s(frame, k = nrow(df)), data = df)
  
  t_full <- 1:131
  fitted_line <- data.frame(frame = t_full, 
                            line_position = predict(fit, data.frame(frame = t_full)))
  return(fitted_line)
} 

# make a reduced iris data set that only contains virginica and versicolor species
iris.small <- filter(iris, Species %in% c("virginica", "versicolor"))

# fit a logistic regression model to the data
glm.out <- glm(Species ~ Petal.Width + Petal.Length + Sepal.Width,
               data = iris.small,
               family = binomial)

# make a data frame with linear predictors from the model and true species assignment
# virginica is 1, versicolor is 0
lr_data <- data.frame(predictor = glm.out$linear.predictors,
                      Species = iris.small$Species)

# calculate an ROC curve
lr_data %>% filter(Species == "virginica") %>%
  mutate(predictor = predictor - 6.7) -> lr_virg
lr_data %>% filter(Species == "versicolor") %>%
  mutate(predictor = predictor + 6.7) -> lr_vers

rbind(lr_virg, lr_vers) %>% 
  mutate(probabilities = exp(predictor)/(1+exp(predictor))) -> new_lr_data
ROC <- calc_ROC(probabilities = new_lr_data$probabilities,
                known_truth = new_lr_data$Species)

# get a density plot for each species
d_virg <- density(filter(lr_data, Species == "virginica")$predictor)
d_vers <- density(filter(lr_data, Species == "versicolor")$predictor)

virg_df <- data.frame(predictor = d_virg$x - 6.7, density = d_virg$y)
vers_df <- data.frame(predictor = d_vers$x + 6.8, density = d_vers$y)

make_plots <- function() {
  movement_range <- c(-30, 42) 
  m <- sine_movement()

  for (i in m$frame){
    cutoff <- m$line_position[i]
    
    if (cutoff < min(movement_range)) cutoff <- min(movement_range)
    if (cutoff > max(movement_range)) cutoff <- max(movement_range)
    
    vers_df %>% filter(predictor < cutoff) %>% mutate(type = factor("TN", levels = c("TN", "FP", "FN", "TP"))) -> TN_area
    vers_df %>% filter(predictor >= cutoff) %>% mutate(type = factor("FP", levels = c("TN", "FP", "FN", "TP"))) -> FP_area
    
    virg_df %>% filter(predictor < cutoff) %>% mutate(type = factor("FN", levels = c("TN", "FP", "FN", "TP"))) -> FN_area
    virg_df %>% filter(predictor >= cutoff) %>% mutate(type = factor("TP", levels = c("TN", "FP", "FN", "TP"))) -> TP_area
    
    p_dist <- ggplot(mapping = aes(x = predictor, y = density, fill = type)) +
      geom_vline(xintercept = cutoff) +
      geom_hline(yintercept = 0, color = "black", size = 0.5, linetype = 2) +
      geom_area(data = TN_area, alpha = 0.7) +
      geom_area(data = FP_area, alpha = 0.7, show.legend = FALSE) +
      geom_area(data = FN_area, alpha = 0.7, show.legend = FALSE) +
      geom_area(data = TP_area, alpha = 0.7, show.legend = FALSE) +
      scale_fill_manual(name = NULL,
                        drop = FALSE,
                        values = c(TN = "#CD8305",
                                   FP = "#FCAE58", 
                                   FN = "#8BCFF4", 
                                   TP = "#127B9F"),
                        breaks = c("TN", "FP", "FN", "TP"),
                        labels = c("true -", "false +", "false -", "true +")) +
      guides(fill = guide_legend(override.aes = list(alpha = 0.7))) +
      scale_x_continuous(limits = c(-45, 50)) +
      theme_cowplot() +
      theme(legend.position = "top",
            legend.text = element_text(size = 14),
            legend.margin = margin(0, 0, 0, 0),
            legend.box.margin = margin(0, 0, -10, 0)) 
    
    new_lr_data %>% filter(Species == "versicolor", predictor < cutoff) %>% tally() -> TN
    new_lr_data %>% filter(Species == "versicolor", predictor >= cutoff) %>% tally() -> FP
    new_lr_data %>% filter(Species == "virginica", predictor < cutoff) %>% tally() -> FN
    new_lr_data %>% filter(Species == "virginica", predictor >= cutoff) %>% tally() -> TP
    
    TP_rate <- TP/(FN+TP)
    FP_rate <- FP/(TN+FP)
    dot_loc <- data.frame(TP_rate = TP_rate$n, FP_rate = FP_rate$n)
    
    p_ROC <- ggplot() +
      geom_abline(intercept = 0, slope = 1) +
      geom_line(data = ROC, aes(x = false_pos, y = true_pos), size = 1) +
      geom_point(data = dot_loc, aes(x = FP_rate, y = TP_rate), size = 5, color = "#FE794F") +
      ggtitle("AUC = 0.853") +
      scale_x_continuous(name = "false positive rate",
                         limits = c(0, 1)) +
      scale_y_continuous(name = "true positive rate",
                         limits = c(0, 1))
    
    p <- plot_grid(p_dist, p_ROC, nrow = 1, ncol = 2, axis = "tb")
    print(p)
  }
} 

gifski::save_gif(make_plots(), "cutoff.gif", delay = 1/13, width = 800, height = 400)
