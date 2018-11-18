library(generativeart)
library(ggplot2)
library(tidyr)

# set the paths
IMG_DIR <- "img/"
IMG_SUBDIR <- "everything/"
IMG_SUBDIR2 <- "handpicked/"
IMG_PATH <- paste0(IMG_DIR, IMG_SUBDIR)

LOGFILE_DIR <- "logfile/"
LOGFILE <- "logfile.csv"
LOGFILE_PATH <- paste0(LOGFILE_DIR, LOGFILE)

# create the directory structure
generativeart::setup_directories(IMG_DIR, IMG_SUBDIR, IMG_SUBDIR2, LOGFILE_DIR)

# include a specific formula, for example:
my_formula <- list(
  x = quote(runif(1, -1, 1) * x_i^2 - sin(y_i^1)),
  y = quote(runif(1, -1, 1) * y_i^2 - cos(x_i^2))
)

# making a data frame with the visualization
df <- generate_data(my_formula)

# set seed
seed <- generate_seeds(1)
set.seed(seed)

# make a file name
file_name <- generate_filename(seed)

# add new image to log file
logfile <- check_logfile_existence()
logfile <- generate_logfile_entry(logfile, formula, seed, file_name)

# make a plot
polar = TRUE
if (polar == TRUE) {
  plot <- df %>%
    ggplot2::ggplot(ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(alpha = 0.1, size = 0, shape = 20) +
    ggplot2::theme_void() +
    ggplot2::coord_fixed() +
    ggplot2::coord_polar()
} else {
  plot <- df %>%
    ggplot2::ggplot(ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(alpha = 0.1, size = 0, shape = 20) +
    ggplot2::theme_void() +
    ggplot2::coord_fixed()
}

# add background and save the plot
final_plot <- plot + theme(panel.background = element_rect(fill = "blue"),
             plot.background = element_rect(fill = "blue"))
print(final_plot)
#ggsave(final_plot, filename = paste(IMG_PATH, file_name, sep = ""), width = 6, height = 6)
