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

**This model can be potentially useful when determining which items will have a marketing value**

1. **Label Creation (`hidden_gem`)**
   - A product is labeled as **1 (hidden gem)** if:  
     - Rating ≥ 4.4 (good quality)  
     - Number of reviews < 50 (low visibility)  
   - Otherwise, it’s **0 (not hidden gem)**.  
   → This turns your dataset into a **binary classification problem**.

---

2. **Features Used (No Direct Leakage)**
   - To avoid the model simply memorizing the label definition, we do **not include `rating` or `reviews` as features**.  
   - Instead, we use **proxy variables** that capture product popularity and brand/category effects indirectly:  
     - **Numeric:** `price_usd`, `sale_price_usd`, `loves_count`  
     - **Categorical:** `brand_name`, `primary_category`  
   - These features allow the model to learn correlations between product characteristics, engagement, and hidden gem potential without directly repeating the label rule.

---


3. **Why Excluding `rating` and `reviews` Matters**
   - If we fed `rating` or `reviews` into the model, it would trivially rediscover the hidden gem rule and give artificially high performance (data leakage).  
   - By using **indirect signals (price, discount, hearts, brand, category)**, the model instead generalizes patterns of what *type of product tends to become a hidden gem*.  
   - This makes the model useful for **new products without many reviews**, where the hidden gem label cannot be computed directly.
---

4. **Model**
   - `XGBClassifier` (gradient boosting decision trees).  
   - Handles nonlinear interactions between numeric and categorical features well.  
   - Example patterns it can learn:
     - Certain brands consistently produce high-rated products.  
     - Products with many “loves” but low discount → higher likelihood of being hidden gems.  
     - Categories like “Fragrance” vs “Skincare” may differ in visibility.

---

5. **Train/Test Split**

   
     ![Alt_text](Results/KakaoTalk_20250905_121559271.png)

   - 80% training, 20% test datasets.
   - The model predicts 89% True negatives, 99% false negatives, 54% true positives and 12% false positives correctly.
   
      **We have significantly low performance on true hidden gems because of the imbalance of data. Only ~12% of the data are hidden gems data**
---
