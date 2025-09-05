# Sephora Product Business & ML Analysis  

**A business sales analysis and application of ML of online Sephora products by taking raw data into an actionable business insight.**

---

## 📊 Business Intelligence

### 🔹 Some sample business insights

1. **Do Sephora-exclusive products excel in sales compared to external products?**

   - Yes! On average, the Sephora-exclusive products receive higher ratings and more hearts per product.  
   - This result shows a positive sign for Sephora’s marketing strategy.  

   ![Exclusive Products](Results/KakaoTalk_20250901_181910168.png)

---

2. **What are some "hidden gem" products that need to be promoted for advertisements?**

   - High rating items that received many hearts but only had few reviews.  

   ![Hidden Gems](Results/KakaoTalk_20250902_110110266.png)

---

3. **A pie chart representing the proportion of the top 10 brands in Sephora**

   ![Top Brands](Results/KakaoTalk_20250902_114848783.png)

---


## 🤖 Machine Learning

### 🔹 Hidden Gem Predictor Model

1. **Label Creation (`hidden_gem`)**
   - A product is labeled as **1 (hidden gem)** if:  
     - Rating ≥ 4.4 (good quality)  
     - Number of reviews < 50 (low visibility)  
   - Otherwise, it’s **0 (not hidden gem)**.  
   → This turns your dataset into a **binary classification problem**.

---

2. **Features Used**
   - **Numeric:** `price_usd`, `sale_price_usd`, `loves_count`  
   - **Categorical:** `brand_name`, `primary_category`

---

3. **Preprocessing Pipelines**
   - **Numeric pipeline:**  
     - Missing values → filled with median (`SimpleImputer(strategy="median")`)  
     - Standardized (mean 0, variance 1) for stability  
   - **Categorical pipeline:**  
     - Missing values → filled with most frequent  
     - Encoded as one-hot vectors (`OneHotEncoder`)  
   → `ColumnTransformer` applies each pipeline to the correct set of columns.

---

4. **Model**
   - `XGBClassifier` (gradient boosting decision trees).  
   - XGBoost handles complex interactions well, especially with mix of numeric + categorical data.

---

5. **Train/Test Split**
   - 80% train, 20% test.  
   - `model.fit()` trains on training data (`X_train, y_train`).  
   - Predictions are compared with `y_test` to evaluate performance.  
