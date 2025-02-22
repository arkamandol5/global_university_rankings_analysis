# ---------------------------------------------------------------------------------
# Script for World University Rankings Data Analysis
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# 1. Loading Libraries
# ---------------------------------------------------------------------------------
library(readr)
library(dplyr)
library(ggplot2)
library(caret)
library(randomForest)
library(rpart)
library(naniar)
library(stringr)
library(corrplot)
library(PerformanceAnalytics)
library(DataExplorer)


# ---------------------------------------------------------------------------------
# 2. Loading the Dataset
# ---------------------------------------------------------------------------------
data <- read_csv("/Users/arkamandol/Downloads/dataset/World University Rankings.csv")

# ---------------------------------------------------------------------------------
# 3. Data Cleaning
# ---------------------------------------------------------------------------------

# Converting score columns to character type and replacing "n/a" with NA
data <- data %>% 
  mutate(scores_teaching = as.character(scores_teaching),
         scores_research = as.character(scores_research),
         scores_citations = as.character(scores_citations),
         scores_industry_income = as.character(scores_industry_income),
         scores_international_outlook = as.character(scores_international_outlook),
         overall_score = as.character(overall_score)) %>%
  mutate(across(c(scores_teaching, scores_research, scores_citations, 
                  scores_industry_income, scores_international_outlook,overall_score), 
                ~na_if(., "n/a")))

# Checking for missing values in 'scores_teaching'
missing <- is.na(data$scores_teaching)
missing_sum <- sum(missing)
missingness_percentage <- (missing_sum / nrow(data)) * 100
print(paste("Missingness in 'scores_teaching':", missingness_percentage, "%"))

# Identifying and removing constant columns
constant_columns <- sapply(data, function(x) length(unique(x)) == 1)
print("Constant columns:")
print(names(data)[constant_columns])
data <- data %>% select(-one_of(names(data)[constant_columns]))

# Visualizing missing data and testing for MCAR
library(naniar)

vis_miss(data) +
  labs(
    title = "Before Data Cleaning" # Add a heading
  )


# Visualize missing data percentages
plot_missing(
  data,
  title = "Percentage of Missing Data", # Add a meaningful title
  ggtheme = theme_minimal()             # Use a clean theme
)
# Statistics of missing data
mcar_test(data)

# Removing rows with NA in 'scores_teaching'
data <- data %>% filter(!is.na(scores_teaching))

# Handling 'overall_score' ranges by calculating averages
calculate_average <- function(x) {
  if (str_detect(x, "–")) {
    nums <- as.numeric(str_split(x, "–", simplify = TRUE))
    return(mean(nums))
  } else {
    return(as.numeric(x))
  }
}
data <- data %>%
  mutate(overall_score = sapply(overall_score, calculate_average))

# Removing duplicates and saving a backup
dataset_backup <- data
data <- data %>% distinct()

# Converting numeric-like columns and percentages
data$stats_number_students <- as.numeric(gsub(",", "", data$stats_number_students))
data$stats_pc_intl_students <- as.numeric(sub("%", "", data$stats_pc_intl_students)) / 100

# Splitting and handling 'stats_female_male_ratio'
data <- data %>%
  mutate(
    female_ratio = as.numeric(gsub(":.*", "", stats_female_male_ratio)),
    male_ratio = as.numeric(gsub(".*:", "", stats_female_male_ratio))
  ) %>%
  select(-stats_female_male_ratio)

# Filling NA in gender ratios with mean values
data$female_ratio[is.na(data$female_ratio)] <- mean(data$female_ratio, na.rm = TRUE)
data$male_ratio[is.na(data$male_ratio)] <- mean(data$male_ratio, na.rm = TRUE)

# Final visualization of missing data
vis_miss(data) +
  labs(
    title = "After Data Cleaning" # Add a heading
  )


# ---------------------------------------------------------------------------------
# 4. Exploratory Data Analysis (EDA)
# ---------------------------------------------------------------------------------

# Converting score columns to numeric
data <- data %>%
  mutate(across(
    c(scores_teaching, scores_research, scores_citations, scores_international_outlook, overall_score),
    as.numeric
  ))

# Removing rows with NA in critical numeric columns
data <- na.omit(data)

# Compute correlation matrix
corr_matrix <- cor(data[, sapply(data, is.numeric)], use = "complete.obs") # Use complete observations only

# Enhanced correlation plot
corrplot(
  corr_matrix,
  method = "shade",       # Use shaded squares for a polished look
  shade.col = NA,         # Disable additional shading color
  tl.col = "black",       # Set text label color to black
  tl.srt = 45,            # Rotate text labels for better readability
  col = colorRampPalette(c("red", "white", "blue"))(200), # Red-white-blue gradient
  addCoef.col = "black",  # Add correlation coefficients in black
  number.cex = 0.7,       # Adjust size of correlation coefficients
  cl.pos = "b",           # Place the color legend at the bottom
  title = "Correlation Matrix", # Add a title
  mar = c(0, 0, 2, 0)     # Adjust margins to fit the title
)

# Scatter plots of features against 'overall_score'
feature_names <- c('scores_teaching', 'scores_research', 'scores_citations', 'scores_international_outlook')
for (feature in feature_names) {
  ggplot(data, aes(x = !!sym(feature), y = overall_score)) +
    geom_point() +
    ggtitle(paste("Scatter Plot of", feature, "vs Overall Score"))
}

# Saving scatter plots to a PDF
pdf("scatter_plots.pdf")
for (feature in feature_names) {
  p <- ggplot(data, aes_string(x = feature, y = "overall_score")) +
    geom_point() +
    ggtitle(paste("Scatter Plot of", feature, "vs Overall Score")) +
    xlab(feature) +
    ylab("Overall Score")
  print(p)
}
dev.off()


# Define the feature names and their corresponding colors
feature_names <- c('scores_teaching', 'scores_research', 'scores_citations', 'scores_international_outlook')
plot_colors <- c("darkgreen", "purple", "orange", "blue") # Unique colors for each plot

# Generate individual scatter plots with unique colors
for (i in seq_along(feature_names)) {
  feature <- feature_names[i]
  color <- plot_colors[i]
  
  # Store the ggplot object
  p <- ggplot(data, aes_string(x = feature, y = "overall_score")) +
    geom_point(color = color, alpha = 0.7, size = 2) +  # Add transparency and size
    ggtitle(paste("Scatter Plot of", feature, "vs Overall Score")) +
    xlab(feature) +
    ylab("Overall Score") +
    theme_minimal() + # Clean theme for better visibility
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  # Print the plot
  print(p)
}


#---------------------------

keep_numerical <- function(data) {
  library(dplyr)
  data %>%
    select_if(is.numeric)
}


new_data <- keep_numerical(data)
print(new_data) 

chart.Correlation(new_data, histogram = TRUE)

# ---------------------------------------------------------------------------------
# 5. Model Building and Evaluation
# ---------------------------------------------------------------------------------

# Splitting data into training and testing sets
set.seed(42) # for reproducibility
trainIndex <- createDataPartition(new_data$overall_score, p = .8, 
                                  list = FALSE, 
                                  times = 1)
data_train <- new_data[trainIndex, ]
data_test <- new_data[-trainIndex, ]

# Defining and evaluating models
# Defining and evaluating models
model_list <- list(
  linear_reg = lm(overall_score ~ ., data = data_train),
  decision_tree = rpart(overall_score ~ ., data = data_train, method = "anova"),
  random_forest = randomForest(overall_score ~ ., data = data_train)
)

results <- list()
for (model_name in names(model_list)) {
  model <- model_list[[model_name]]
  predictions <- predict(model, newdata = data_test)
  
  # Important Evaluation Metrics
  mae <- mean(abs(predictions - data_test$overall_score))
  rmse <- sqrt(mean((predictions - data_test$overall_score)^2))
  r2 <- cor(predictions, data_test$overall_score)^2
  mape <- mean(abs((predictions - data_test$overall_score) / data_test$overall_score)) * 100
  
  # Store results
  results[[model_name]] <- list(
    MAE = mae,
    RMSE = rmse,
    R2 = r2,
    MAPE = mape
  )
}

# Print results
print(results)


# Random Forest Feature Importance
# Random Forest Feature Importance with Colorful Bars
importance_df <- as.data.frame(randomForest(overall_score ~ ., data = data_train)$importance)

ggplot(importance_df, aes(x = reorder(row.names(importance_df), IncNodePurity), y = IncNodePurity, fill = IncNodePurity)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_gradient(low = "blue", high = "red") + # Gradient from blue to red
  xlab("Features") +
  ylab("Importance") +
  ggtitle("Feature Importances in Random Forest Model") +
  theme_minimal() + # Use a clean theme
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"), # Centered title
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

# Plotting the result comparison
# Combine results into a data frame for visualization
results_df <- do.call(rbind, lapply(results, as.data.frame))
results_df$model <- rownames(results_df)
rownames(results_df) <- NULL

# Reshape the data for ggplot
results_long <- pivot_longer(
  results_df,
  cols = -model, # Keep the "model" column intact
  names_to = "Metric",
  values_to = "Value"
)

# Plot the comparison of metrics across models
ggplot(results_long, aes(x = Metric, y = Value, fill = model)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Model Performance Comparison",
    x = "Metrics",
    y = "Values",
    fill = "Model"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )

