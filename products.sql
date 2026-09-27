Select * From products;

-- Descriptive Stats [EDA]
SELECT 
    MIN(price) AS min_price,
    ROUND(CAST(PERCENTILE_CONT(1.0 / 3.0) WITHIN GROUP (ORDER BY price) AS numeric), 2) AS p33,
    ROUND(CAST(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY price) AS numeric), 2) AS median_price,
	MAX(price) AS max_price,
    ROUND(CAST(PERCENTILE_CONT(2.0 / 3.0) WITHIN GROUP (ORDER BY price) AS numeric), 2) AS p66,
	ROUND(AVG(price), 2) AS avg_price
FROM products;

-- Categorising products based on price
CREATE OR REPLACE VIEW dim_products AS
SELECT 
    productid,
    productname,
    price,
    
    CASE 
        WHEN price < 100 THEN 'Low'          
        WHEN price BETWEEN 100 AND 260 THEN 'Medium'
        ELSE 'High'                         
    END AS price_category
FROM products;

-- Cleaned View
SELECT * FROM dim_products;