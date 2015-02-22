# Load used packages
library(package = ggplot2)
library(package = dplyr)


# Read the training dataset
training <- read.csv(file = "./data/pml-training.csv", stringsAsFactors = FALSE,
                     row.names = 1, na.strings = c("#DIV/0!", "", "NA"))

# Metadata variables
meta <- c("classe", "user_name",
          "raw_timestamp_part_1", "raw_timestamp_part_2",
          "cvtd_timestamp", "new_window", "num_window")

# NA proportion
NAs <- sapply(X = training[!names(training) %in% meta],
              FUN = function(col) mean(is.na(col)))

# Variables used for window summaries
mostly_NA <- names(NAs)[NAs > 0.95]

# Remove summaries and summary variables
training <- training %>%
  filter(new_window == "no") %>%
  select(-one_of(mostly_NA), -new_window)

# Storage modes to serach for non-numeric variables
modes <- sapply(X = training, FUN = mode)

# Zero-variance variables
vars <- sapply(X = training[, modes == "numeric"], FUN = var, na.rm = TRUE)
names(vars)[vars == 0]

# Search non-numeric values
table(grep(pattern = "[^-0-9.]",
           x = unlist(training[, modes != "numeric" &
                                  !names(training) %in% meta]),
           value = TRUE))

# Exclude metadata variables from the predictors
predictors <- names(training)[!names(training) %in% meta]

# Clean dataset including only class and predictors
training_clean <- training[, c("classe", predictors)]

# Example of non-linear relationship between features
qplot(data = training_clean, x = roll_forearm, y = pitch_forearm,
      color = classe, size = I(0.5)) + theme_classic()
