# Weight lifting classification
Oscar de León  







### Overview

This report addresses my Practical Machine Learning ([predmachlearn-011](https://www.coursera.org/course/predmachlearn)) course project.
It includes a description of the data processing steps, the rationale for model selection, the _model building process_ the use of _cross-validation for estimation of the out of sample error_.

This compiled report contains code chunks to show the data analysis as it was performed.
The lengthy code chunks are collapsed for readability (in [compatible browsers](http://www.w3schools.com/tags/tag_details.asp)) and can be expanded for revision by clicking on the sentences labeled as "section collapsed for readability".
For example:

<details><summary>
If the browser you are using does not support this feature...
(section collapsed for readability)
</summary>
this text is shown upon page loading (as are the code chunks).
Otherwise, it (and the code chunks) stay collapse until you open them.
</details>

The code is also available for review in the [repository](https://github.com/odeleongt/predmachlearn-011) containing this github page.

</br>

#### Getting and preparing data


```r
# Get data (downloads only if not available locally)
source(file = "./scripts/get_data.R")
```

<details>
<summary>**Read in data and clean up** (section collapsed for readability)

I obtained the data as specified in the instructions, and loaded the training set in R.
The dataset contained missing observations marked in a variety of ways (_i.e._ `NA`, `""`, `#DIV/0!`),
all of which were explicitly marked as NA upon reading the data.
I avoided the use of factors up to the model building,
to prevent errors due to incompatible levels.

I removed from the training data all the window summary rows (marked with `new_window == "yes"` in the training dataset)
and all the summary columns (which contained mostly `NA`s, except for the summary rows).

</summary>

```r
source(file = "./scripts/prepare_data.R", echo = TRUE)
```

```

> training <- read.csv(file = "./data/pml-training.csv", 
+     stringsAsFactors = FALSE, row.names = 1, na.strings = c("#DIV/0!", 
+         "", "NA" .... [TRUNCATED] 

> meta <- c("classe", "user_name", "raw_timestamp_part_1", 
+     "raw_timestamp_part_2", "cvtd_timestamp", "new_window", "num_window")

> NAs <- sapply(X = training[!names(training) %in% meta], 
+     FUN = function(col) mean(is.na(col)))

> mostly_NA <- names(NAs)[NAs > 0.95]

> training <- subset(x = training, subset = new_window == 
+     "no", select = names(training)[!names(training) %in% c(mostly_NA, 
+     "new_window" .... [TRUNCATED] 

> modes <- sapply(X = training, FUN = mode)

> vars <- sapply(X = training[, modes == "numeric"], 
+     FUN = var, na.rm = TRUE)

> predictors <- names(training)[!names(training) %in% 
+     meta]

> training_clean <- training[, c("classe", predictors)]
```

```r
# Set classe to factor, for use with randomForest
training_clean$classe <- factor(training_clean$classe)
```
</details>

</br>


<details>
<summary>**Using cross validation** (section collapsed for readability)

I used single set cross validation to estimate the out of sample error of the model.
For this I split the training dataset in training (60%) and validation (40%) datasets,
and used the validation set to estimate the error as described in a section below.

</summary>

```r
set.seed(2015-02-22) # Set seed for reproducibility
rows_for_training <- sample(x = 1:nrow(training_clean),
                            size = ceiling(nrow(training_clean) * 0.6),
                            replace = FALSE)
training <- training_clean[rows_for_training, ]
validation <- training_clean[-rows_for_training, ]
```
</details>


</br>

### Building the model

In this section I describe the model building process.
As exemplified in the figure below, there are non-linear relationships between the features contained in the dataset.
Thus, I opted to build a randomForest model for its accuracy and to avoid using linear models.


```r
qplot(data = training, x = roll_forearm, y = pitch_forearm,
      color = classe, size = I(0.5)) + theme_classic()
```

![](report_files/figure-html/descriptive_plot-1.png) 

I trained the model with the `randomForest` package, using the default settings. 


```r
set.seed(2015-02-22) # Set seed for reproducibility
trained <- randomForest(classe ~ ., data = training)
```

<details>
<summary>
Show model output (section collapsed for readability)
</summary>

```

Call:
 randomForest(formula = classe ~ ., data = training) 
               Type of random forest: classification
                     Number of trees: 500
No. of variables tried at each split: 7

        OOB estimate of  error rate: 0.77%
Confusion matrix:
     A    B    C    D    E class.error
A 3271    4    0    0    2 0.001830943
B   17 2182    8    1    0 0.011775362
C    0   18 2021    4    0 0.010768478
D    0    0   26 1875    0 0.013677012
E    0    1    1    7 2092 0.004283674
```
</details>


</br>

### Out-of-sample error estimation

Although the model output shows an OOB estimate of error rate (0.77%), 
I used the generated model to predict the class for each observation in the validation set
to estimate the out of sample error as required by the project instructions.


```r
validate_prediction <- predict(object = trained, newdata = validation)
(accuracy <- mean(validate_prediction == validation$classe))
```

```
## [1] 0.9942753
```

This results in an estimated 0.9942753 accuracy, or 0.6% out of sample error.


</br>

### The model in action

Using the developed model, I predicted the class for each observation in the test set and obtained all 20 results correctly.


```r
test <- read.csv(file = "./data/pml-testing.csv", stringsAsFactors = FALSE,
                     row.names = 1, na.strings = c("#DIV/0!", "", "NA"))
(test_prediction <- predict(object = trained, newdata = test))
```

```
##  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 
##  B  A  B  A  A  E  D  B  A  A  B  C  B  A  E  E  A  B  B  B 
## Levels: A B C D E
```





</br>

<details><summary>
Released under a [CC BY-SA](https://creativecommons.org/licenses/by-sa/4.0) license.
</summary>
This analysis uses data published under CC BY-SA, so it is considered a derivative use of the [Weight Lifting Exercises Dataset](http://groupware.les.inf.puc-rio.br/har#weight_lifting_exercises) by [Groupware@LES](http://groupware.les.inf.puc-rio.br/) and released under a compatible license as required (as declared in the repository README file). 
</details>
