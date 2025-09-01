DROP TABLE IF EXISTS products;

CREATE TABLE products (
  product_id         text PRIMARY KEY,
  product_name       text,
  brand_id           text,
  brand_name         text,
  loves_count        integer,
  rating             numeric(3,2),
  reviews            integer,
  size               text,
  variation_type     text,
  variation_value    text,
  variation_desc     text,
  ingredients        text,
  price_usd          numeric(10,2),
  value_price_usd    numeric(10,2),
  sale_price_usd     numeric(10,2),
  limited_edition    boolean,
  new                boolean,
  online_only        boolean,
  out_of_stock       boolean,
  sephora_exclusive  boolean,
  highlights         text,
  primary_category   text,
  secondary_category text,
  tertiary_category  text,
  child_count        integer,
  child_max_price    numeric(10,2),
  child_min_price    numeric(10,2)
);



COPY products
FROM 'C:/Users/User/OneDrive/Github/sql-product-analytics/product_info.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');




-- Data Quality Check

select count(*) as rows,
	min(price_usd) as min_price, max(price_usd) as max_price
	min(rating)    as min_rating,max(rating)    as max_rating

from products;


select
	sum((product_id is null)::int)	as miss_product_id,
	sum((brand_name is null)::int)	as miss_brand,
	sum((primary_category is null)::int)	as miss_category,
	sum((price_usd is null)::int)	as miss_rate,
	sum((rating is null)::int)	as miss_rating







-- Helper Function
-- price bands for quick slicing
CREATE OR REPLACE VIEW v_product_enriched AS
SELECT p.*,
       (price_usd > sale_price_usd)                    AS discounted,
       (price_usd - sale_price_usd)                    AS discount_abs,
       CASE
         WHEN price_usd IS NULL THEN NULL
         WHEN price_usd < 15  THEN 'Under $15'
         WHEN price_usd < 30  THEN '$15–$29'
         WHEN price_usd < 50  THEN '$30–$49'
         WHEN price_usd < 80  THEN '$50–$79'
         WHEN price_usd < 120 THEN '$80–$119'
         ELSE '$120+'
       END AS price_band
FROM products p;

-- (Optional) explode "highlights" list into one tag per row
-- Works if highlights is a comma-separated or JSON-ish string.
CREATE TABLE IF NOT EXISTS product_tags (
  product_id TEXT,
  tag        TEXT
);

-- Simple splitter; adjust regex if your highlights is strict JSON.
TRUNCATE product_tags;
INSERT INTO product_tags (product_id, tag)
SELECT product_id,
       NULLIF(trim(both ' "[]' FROM t), '') AS tag
FROM (
  SELECT product_id,
         unnest(regexp_split_to_array(COALESCE(highlights,''), ',')) AS t
  FROM products
) s
WHERE NULLIF(trim(both ' "[]' FROM t), '') IS NOT NULL;

--








--Bivariate EDA (relationships)

-- Are discounts associated with more popularity?
SELECT discounted,
       ROUND(AVG(rating),2)  AS avg_rating,
       AVG(reviews)          AS avg_reviews,
       AVG(loves_count)      AS avg_loves,
       ROUND(AVG(discount_abs),2) AS avg_discount_abs
FROM v_product_enriched
GROUP BY discounted;


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

