library(generativeart)
library(tidyverse)

# set the paths
IMG_DIR <- "images/"
IMG_SUBDIR <- "./"
IMG_SUBDIR2 <- "./"
IMG_PATH <- paste0(IMG_DIR, IMG_SUBDIR)

LOGFILE_DIR <- "logfile/"
LOGFILE <- "logfile.csv"
LOGFILE_PATH <- paste0(LOGFILE_DIR, LOGFILE)

# create the directory structure
generativeart::setup_directories(IMG_DIR, IMG_SUBDIR, IMG_SUBDIR2, LOGFILE_DIR)

get_circle_data <- function(center = c(0,0), radius = 1, npoints = 1000){
  tt <- seq(0, 2*pi, length.out = npoints)
  xx <- center[1] + radius * cos(tt)
  yy <- center[2] + radius * sin(tt)
  return(data.frame(x = xx, y = yy))
}

generate_data <- function(df) {
  print("generate data")
  df2 <- df %>% 
    mutate(xend = x,
           yend = y) %>% 
    select(-x, -y)
  df2 <- df2[sample(nrow(df2)),]
  df <- bind_cols(df, df2)
  return(df)
} 

generate_plot <- function(df, file_name, coord, line_color) {
  print("generate plot")
  plot <- df %>% 
    ggplot() +
    geom_segment(aes(x = x, y = y, xend = xend, yend = yend), color = line_color, size = 0.25, alpha = 0.6) +
    theme_void() +
    coord_equal()
  
  print("image saved...")
  plot
}

x <- 3
y <- c(2,2)
n <- 100
df1 <- get_circle_data(center = x, radius = y, npoints = n)
df2 <- generate_data(df1)
plot <- generate_plot(df2, line_color = "black")

# add background
output_plot <- plot #+ theme(plot.background = element_rect(fill = "#f8d0b0"))
print(output_plot)

# save an image
save_file = TRUE
if (save_file){
  file_name <- paste0(format(Sys.time(), "%Y-%m-%d-%H-%M"), 
                      "_center_", y[1], y[2], "_radius_", x, "_npoints_", n,".png")
  ggsave(output_plot, filename = paste(IMG_PATH, file_name, sep = ""), width = 6, height = 6)
}

