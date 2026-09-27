SELECT * FROM customer_reviews;


CREATE OR REPLACE VIEW fact_customer_reviews AS
SELECT 
    reviewid,
    customerid,
    productid,
	
    TO_CHAR(CAST(reviewdate AS DATE), 'DD-MM-YYYY') AS review_date,
    
    rating,
    
    REPLACE(reviewtext, '  ', ' ') AS review_text   -- Replacing double spaces with single spaces 
FROM customer_reviews;

-- Output table
SELECT * FROM fact_customer_reviews;