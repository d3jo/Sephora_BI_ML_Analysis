-- Are discounts associated with more popularity?
SELECT discounted,
       ROUND(AVG(rating),2)  AS avg_rating,
       AVG(reviews)          AS avg_reviews,
       AVG(loves_count)      AS avg_loves,
       ROUND(AVG(discount_abs),2) AS avg_discount_abs
FROM v_product_enriched
GROUP BY discounted;
--

-- Brand price positioning (only brands with enough products)
SELECT brand_name,
       COUNT(*)                    AS products,
       ROUND(AVG(price_usd),2)     AS avg_price,
       ROUND(MIN(price_usd),2)     AS min_price,
       ROUND(MAX(price_usd),2)     AS max_price,
       ROUND(AVG(rating),2)        AS avg_rating
FROM products
GROUP BY brand_name
HAVING COUNT(*) >= 5
ORDER BY avg_price DESC
LIMIT 30;
--

-- Most Loved Brands and Products
SELECT brand_name,
       COUNT(*) AS products,
       SUM(loves_count) AS total_loves,
       ROUND(AVG(rating),2) AS avg_rating
FROM products
GROUP BY 1
ORDER BY total_loves DESC
LIMIT 15;
--

-- Top 20 products by rating with minimum review threshold
SELECT product_name, brand_name, primary_category, rating, reviews, price_usd
FROM products
WHERE reviews >= 100
ORDER BY rating DESC, reviews DESC
LIMIT 20;
--

CREATE OR REPLACE VIEW v_product_enriched AS
SELECT
  *,
  (price_usd > sale_price_usd)                          AS discounted,
  GREATEST(price_usd - sale_price_usd, 0)               AS discount_abs,
  CASE WHEN price_usd > 0
       THEN GREATEST((price_usd - sale_price_usd)/price_usd, 0)
       ELSE NULL END                                    AS discount_pct,
  CASE
    WHEN price_usd IS NULL THEN NULL
    WHEN price_usd < 15  THEN 'Under $15'
    WHEN price_usd < 30  THEN '$15–$29'
    WHEN price_usd < 50  THEN '$30–$49'
    WHEN price_usd < 80  THEN '$50–$79'
    WHEN price_usd < 120 THEN '$80–$119'
    ELSE '$120+'
  END AS price_band
FROM products;



-- Do Sephora-exclusive products actually perform better?

SELECT sephora_exclusive,
       COUNT(*) AS products,
       ROUND(AVG(rating),2)   AS avg_rating,
       ROUND(AVG(reviews),1)  AS avg_reviews,
       ROUND(AVG(loves_count),1) AS Loves_per_product
FROM products
GROUP BY sephora_exclusive;

-- Which features of the item helps sales ("Oil Free, Full Coverage, Waterproof")?
SELECT tag,
       COUNT(DISTINCT product_id) AS products,
       ROUND(AVG(p.rating),2)     AS avg_rating,
       ROUND(AVG(p.price_usd),2)  AS avg_price,
       ROUND(AVG(p.reviews),1)    AS avg_reviews
FROM product_tags t
JOIN products p USING (product_id)
GROUP BY tag
ORDER BY avg_reviews DESC
LIMIT 20;


-- Finding hidden gems of items where there is high rating but little tractions
-- Finds the top 20 items with less than 50 reviews but has more than 4.6 rating.
SELECT 
    product_id,
    product_name,
    brand_name,
    primary_category,
    rating,
    reviews,
    loves_count,
    price_usd
FROM products
WHERE rating >= 4.7                -- excellent quality
  AND COALESCE(reviews,0) < 50     -- few reviews = low traction
ORDER BY rating DESC, reviews ASC
LIMIT 20;

