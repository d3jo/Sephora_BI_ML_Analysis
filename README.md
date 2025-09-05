# Sephora Product Business & ML Analysis
**A business sales analysis and application of ML of online Sephora products by taking raw data into an actionable business insight.**


<h1>Business Intelligence</h1>

**Some sample business insights:**

**1. Do Sephora-exclusive products excel in sales compared to external products?**

   Yes! On average, the Sephora-exclusive products receive higher ratings and more hearts per product.
   This result shows a positive sign for Sephora's marketing strategy.

   
![Alt_text](Results/KakaoTalk_20250901_181910168.png)


**2. What are some "hidden gem" products that need to be promoted for advertisements?**

   High rating items that received many hearts but only had few reviews.
![Alt_text](Results/KakaoTalk_20250902_110110266.png)



**A pie chart representing the proportion of the top 10 brands in Sephora**
![Alt_text](Results/KakaoTalk_20250902_114848783.png)


<h1>Machine Learning</h1>


**1. Hidden Gem? Predictor Model**
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Hidden Gem Classifier — Training & Results</title>
  <style>
    :root { --fg:#1f2937; --muted:#6b7280; --bg:#ffffff; --card:#f8fafc; --border:#e5e7eb; }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, Helvetica, Arial, "Apple Color Emoji","Segoe UI Emoji"; color: var(--fg); background: var(--bg); }
    .container { max-width: 960px; margin: 48px auto; padding: 0 20px; }
    h1 { font-size: 2rem; margin: 0 0 8px; }
    h2 { font-size: 1.25rem; margin: 28px 0 12px; }
    p, li { line-height: 1.6; }
    .lead { color: var(--muted); margin-bottom: 22px; }
    .card { background: var(--card); border: 1px solid var(--border); border-radius: 14px; padding: 18px; }
    code, pre { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace; }
    pre { background: #0b1020; color: #e5e7eb; padding: 14px; border-radius: 10px; overflow: auto; }
    .grid { display: grid; gap: 14px; }
    @media (min-width: 800px) { .grid-2 { grid-template-columns: 1fr 1fr; } }
    table { width: 100%; border-collapse: collapse; background: white; overflow: hidden; border-radius: 10px; border: 1px solid var(--border); }
    th, td { text-align: right; padding: 10px 12px; border-bottom: 1px solid var(--border); }
    th:first-child, td:first-child { text-align: left; }
    thead th { background: #f3f4f6; font-weight: 600; }
    tfoot td { background: #fbfbfd; font-weight: 600; }
    .note { font-size: 0.95rem; color: var(--muted); }
    .pill { display: inline-block; padding: 2px 8px; border: 1px solid var(--border); border-radius: 999px; background: #ffffff; font-size: 0.85rem; }
    .bad { color: #b91c1c; }
    .ok  { color: #047857; }
  </style>
</head>
<body>
  <main class="container">
    <h1>Hidden Gem Classifier — Training & Results</h1>
    <p class="lead">Predict whether a product is a <strong>hidden gem</strong> (high rating, low review count) using an XGBoost model wrapped in a scikit-learn pipeline.</p>

    <section class="card">
      <h2>Problem Setup</h2>
      <ul>
        <li><strong>Label (binary):</strong> <code>hidden_gem = 1</code> if <code>rating ≥ 4.4</code> and <code>reviews &lt; 50</code>; else <code>0</code>.</li>
        <li><strong>Features</strong>
          <ul>
            <li><em>Numeric:</em> <code>price_usd</code>, <code>sale_price_usd</code>, <code>loves_count</code></li>
            <li><em>Categorical:</em> <code>brand_name</code>, <code>primary_category</code></li>
          </ul>
        </li>
      </ul>
    </section>

    <section class="grid grid-2">
      <div class="card">
        <h2>Training Pipeline</h2>
        <ol>
          <li><strong>Numeric preprocessing:</strong> median imputation → standard scaling.</li>
          <li><strong>Categorical preprocessing:</strong> most-frequent imputation → one-hot encoding.</li>
          <li><strong>Model:</strong> <code>XGBClassifier</code> (gradient-boosted trees).</li>
          <li><strong>Split:</strong> 80% train / 20% test with <code>train_test_split</code>.</li>
        </ol>
      </div>
      <div class="card">
        <h2>Key Code (excerpt)</h2>
        <pre><code># label
df["hidden_gem"] = ((df["rating"] &gt;= 4.4) &amp; (df["reviews"].fillna(0) &lt; 50)).astype(int)

# pipelines and model (scikit-learn + XGBoost)
model = Pipeline(steps=[
  ("preprocessor", ColumnTransformer([
    ("num", Pipeline([("imputer", SimpleImputer("median")),
                      ("scaler", StandardScaler())]), ["price_usd","sale_price_usd","loves_count"]),
    ("cat", Pipeline([("imputer", SimpleImputer("most_frequent")),
                      ("onehot", OneHotEncoder(handle_unknown="ignore"))]),
                      ["brand_name","primary_category"])
  ])),
  ("model", XGBClassifier(use_label_encoder=False, eval_metric="logloss"))
])</code></pre>
      </div>
    </section>

    <section>
      <h2>Test Results (Classification Report)</h2>
      <table>
        <thead>
          <tr>
            <th>Class</th><th>Precision</th><th>Recall</th><th>F1-score</th><th>Support</th>
          </tr>
        </thead>
        <tbody>
          <tr><td>0 (not hidden gem)</td><td>0.89</td><td>0.99</td><td>0.93</td><td>1489</td></tr>
          <tr><td>1 (hidden gem)</td><td>0.54</td><td class="bad">0.12</td><td class="bad">0.20</td><td>210</td></tr>
        </tbody>
        <tfoot>
          <tr><td>accuracy</td><td></td><td></td><td>0.88</td><td>1699</td></tr>
          <tr><td>macro avg</td><td>0.72</td><td>0.55</td><td>0.57</td><td>1699</td></tr>
          <tr><td>weighted avg</td><td>0.85</td><td>0.88</td><td>0.84</td><td>1699</td></tr>
        </tfoot>
      </table>
      <p class="note">High accuracy is driven by the majority class (0). The minority class (1) recall is low (0.12), meaning most true hidden gems are missed.</p>
    </section>

    <section class="grid grid-2">
      <div class="card">
        <h2>How to Read These Metrics</h2>
        <ul>
          <li><strong>Precision</strong> (class 1 = 0.54): When we predict “hidden gem,” we’re correct ~54% of the time.</li>
          <li><strong>Recall</strong> (class 1 = <span class="bad">0.12</span>): We only catch 12% of actual hidden gems (many are missed).</li>
          <li><strong>F1</strong> (class 1 = 0.20): Harmonic mean of precision/recall → weak for the minority class.</li>
          <li><strong>Accuracy</strong> (0.88): Looks good, but is misleading with imbalanced data.</li>
        </ul>
      </div>
      <div class="card">
        <h2>Why It’s Hard & How to Improve</h2>
        <ul>
          <li><span class="pill">Class imbalance</span>: hidden gems are rare (~12%).</li>
          <li><strong>Balance the classes</strong> with XGBoost’s <code>scale_pos_weight = negatives / positives</code>, or use over/under-sampling.</li>
          <li><strong>Tune the decision threshold</strong> (use probabilities, not default 0.5) to boost recall for class 1.</li>
          <li><strong>Engineer features</strong>: e.g., <code>discount_pct</code>, <code>hearts_per_review</code>, <code>price_delta = price - sale_price</code>.</li>
        </ul>
      </div>
    </section>
