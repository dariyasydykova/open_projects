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
                     function(x) sum(pos_probs >= x)/pos) # true pos. rate
  false_pos <- sapply(probabilities,
                      function(x) sum(neg_probs >= x)/neg)
  if (is.null(model.name))
    result <- data.frame(true_pos, false_pos)
  else
    result <- data.frame(true_pos, false_pos, model.name)
  
  result %>% add_row(true_pos = 0, false_pos = 0) %>% arrange(false_pos, true_pos)
}

# this function calculates precision and recall
calc_PR <- function(probabilities, known_truth, model.name = NULL)
{
  outcome <- as.numeric(factor(known_truth))-1
  pos <- sum(outcome) # total known positives
  pos_probs <- outcome*probabilities # probabilities for known positives
  neg_probs <- (1-outcome)*probabilities # probabilities for known negatives
  recall <- sapply(probabilities,
                   function(x) sum(pos_probs >= x)/pos) 
  precision <- sapply(probabilities,
                      function(x) sum(pos_probs >= x)/(sum(pos_probs >= x)+sum(neg_probs >= x)))
  if (is.null(model.name))
    result <- data.frame(precision, recall)
  else
    result <- data.frame(precision, recall, model.name)
  
  result %>% arrange(recall, desc(precision)) 
}

# read in a biopsy data set
biopsy <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/biopsy.csv")

# fit a logistic regression model
# the predictor variables with p-value > 0.5 have been removed
glm.out <- glm(outcome ~ clump_thickness +
                 uniform_cell_shape +
                 marg_adhesion +
                 bare_nuclei +
                 bland_chromatin +
                 normal_nucleoli,
               data=biopsy,
               family=binomial)

# make a data frame with linear predictors from the model and true species assignment
lr_data <- data.frame(predictor = glm.out$linear.predictors, 
                      outcome = biopsy$outcome, 
                      time = 1)

# seperate the data set and remove observations for malignant tumors randomly
benign <- lr_data %>% filter(outcome == "benign")
malignant <- lr_data %>% filter(outcome == "malignant")
reduced <- malignant[round(runif(50, 1, nrow(malignant))),]
anim_data <- benign %>% rbind(reduced) %>% mutate(time = 2) %>% rbind(lr_data)

# make an animation with distributions of linear predictors
p_dist <- ggplot(anim_data) +
  geom_density(aes(x = predictor, fill = outcome, stat(count)), alpha = 0.7, color = NA) +
  geom_hline(yintercept = 0, color = "black", size = 0.5, linetype = 2) +
  scale_x_continuous(limits = c(-15, 15)) +
  scale_fill_manual(values = c("#C04A56", "#3D8CF1")) +
  transition_states(time, transition_length = 1, state_length = 1) +
  ggtitle(" ") + # adding an emtpy title to align y axis with ROC plot
  theme_cowplot() +
  theme(legend.position = "none")
