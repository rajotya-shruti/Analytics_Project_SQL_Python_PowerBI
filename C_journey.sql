SELECT * FROM customer_journey

-- Verification Query - Identify Duplicates

WITH duplicate_check AS (
    SELECT 
        journeyid,
        customerid,
        productid,
        visitdate,
        stage,
        action,
        duration,
        ROW_NUMBER() OVER (
            PARTITION BY customerid, productid, visitdate, stage, action
            ORDER BY journeyid
        ) AS row_num
    FROM customer_journey
)
SELECT * 
FROM duplicate_check 
WHERE row_num > 1;



-- Calculating Average Duration to replace NULL values

SELECT ROUND(AVG(duration), 2) AS avg_duration 
FROM customer_journey 
WHERE duration IS NOT NULL;

-- Impute missing durations with average, and changing date format

CREATE VIEW fact_customer_journey AS
WITH ranked_journey AS (
    SELECT 
        journeyid,
        customerid,
        productid,
        visitdate,
        stage,
        action,
        duration,
        
        -- Window Function: Assign row numbers to flag duplicate interactions
        ROW_NUMBER() OVER (
            PARTITION BY customerid, productid, visitdate, stage, action
            ORDER BY journeyid
        ) AS row_num
    FROM customer_journey
),
avg_duration_cte AS (
    -- Calculate average duration 
    SELECT AVG(duration) AS overall_avg_duration
    FROM customer_journey
    WHERE duration IS NOT NULL
)
SELECT 
    rj.journeyid AS journey_id,
    rj.customerid AS customer_id,
    rj.productid AS product_id,
    
    -- Date Formatting converting YYYY-MM-DD to DD-MM-YYYY 
    TO_CHAR(CAST(rj.visitdate AS DATE), 'DD-MM-YYYY') AS visit_date,
    
    rj.stage AS journey_stage,
    rj.action AS user_action,
    
    -- Imputation replace NULL duration with rounded average session duration
    ROUND(
        COALESCE(CAST(rj.duration AS numeric), (SELECT overall_avg_duration FROM avg_duration_cte)), 
        2
    ) AS duration_seconds
FROM ranked_journey rj
-- Deduplication Filter: Keeping only the first occurrence of each unique action
WHERE rj.row_num = 1;

--  Output

SELECT * FROM fact_customer_journey;