# 📊 Global University Rankings Analysis

## 🔍 **Project Overview**

This project focuses on analyzing global university rankings using advanced data science techniques. Leveraging data from renowned global ranking systems (such as **Times Higher Education**), the goal is to identify the key factors that influence university rankings and develop predictive models for forecasting overall scores.

The analysis covers data cleaning, exploratory data analysis (EDA), feature selection, and predictive modeling using regression techniques like Linear Regression, Decision Tree, and Random Forest.

---

## 📁 **Project Structure**

```
/global_university_rankings_analysis
│
├── dataset/                                  # Contains the university rankings dataset
│   └── World University Rankings.csv
│
├── plots/                                    # Contains generated plots and visual outputs
│   ├── model_performance_comparison.png
│   ├── feature_importance_in_random_forest.png
│
├── edu_rank_predictor.R                      # Main R script for data analysis and modeling
│
├── Global University Insights Data Driven Analysis.docx  # Detailed report with analysis results
│
├── README.md                                 # Project documentation
└── .gitignore                                # Specifies files to be ignored by Git
```

---

## 📊 **Features and Analysis Performed**

1. **Data Cleaning**
    - Handling missing values (using deletion and imputation techniques).
    - Transforming non-numeric fields (percentages and ranges).
    - Normalizing and standardizing numeric features.

2. **Exploratory Data Analysis (EDA)**
    - Correlation matrix visualization.
    - Scatter plots for key features vs. overall score.
    - Distribution and outlier detection.

3. **Feature Selection**
    - Selected features based on correlation and importance:
        - `scores_research`
        - `scores_citations`
        - `scores_teaching`
        - `scores_international_outlook`

4. **Predictive Modeling**
    - **Linear Regression**: Baseline model.
    - **Decision Tree**: Handles non-linear relationships.
    - **Random Forest**: Best-performing model based on MAE, RMSE, and R².

5. **Model Evaluation**
    - Metrics used:
        - Mean Absolute Error (MAE)
        - Root Mean Squared Error (RMSE)
        - R² Score
        - Mean Absolute Percentage Error (MAPE)

6. **Feature Importance**
    - Visualizing which features contribute most to predicting university rankings.

---

## 📈 **Model Performance Comparison**

This plot compares the **Mean Absolute Error (MAE), Root Mean Squared Error (RMSE), R² Score, and Mean Absolute Percentage Error (MAPE)** across different models:

![Model Performance Comparison](/Users/arkamandol/Documents/git projects/global_university_rankings_analysis/plots/model performance comparison.png)

---

## 🔥 **Feature Importance in Random Forest Model**

This plot highlights the key features that contribute most to university rankings:

![Feature Importance in Random Forest](/Users/arkamandol/Documents/git projects/global_university_rankings_analysis/plots/feature importance in random forest.png)

---

## 🚀 **Usage Instructions**

### 📂 Run Data Cleaning
```r
Rscript edu_rank_predictor.R --step clean
```

### 📊 Run Exploratory Data Analysis (EDA)
```r
Rscript edu_rank_predictor.R --step eda
```

### 🔮 Run Predictive Modeling
```r
Rscript edu_rank_predictor.R --step model
```

---

## 🤝 **Contributing Guidelines**
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Submit a pull request.

---

## 📬 **Contact**

For any queries, feel free to reach out:

- **Email**: [arkamandol56@gmail.com](mailto:arkamandol56@gmail.com)
- **GitHub**: [arkamandol5](https://github.com/arkamandol5)
- **LinkedIn**: [Arka Mandol](https://www.linkedin.com/in/arka-mandol-0b249716a/)

---

## 🙏 **Acknowledgments**
- Times Higher Education for dataset inspiration.
- R and Python data science communities.
- Research papers and open-source contributors that inspired this analysis.

