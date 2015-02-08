
# Data location
train_uri <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test_uri <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

# Download data
if(!file.exists("./data/pml-training.csv")){
  download.file(url = train_uri, destfile = "./data/pml-training.csv")
}

if(!file.exists("./data/pml-testing.csv")){
  download.file(url = test_uri, destfile = "./data/pml-testing.csv")
}
