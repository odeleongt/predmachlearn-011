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
training <- subset(x = training, subset = new_window == "no",
                   select = names(training)[!names(training) %in%
                                              c(mostly_NA, "new_window")])

# Storage modes to serach for non-numeric variables
modes <- sapply(X = training, FUN = mode)

# Zero-variance variables
vars <- sapply(X = training[, modes == "numeric"], FUN = var, na.rm = TRUE)

# Exclude metadata variables from the predictors
predictors <- names(training)[!names(training) %in% meta]

# Clean dataset including only class and predictors
training_clean <- training[, c("classe", predictors)]
