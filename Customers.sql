SELECT * FROM customers;

SELECT * FROM geography;

-- Join customers with geography to include location details (city, country).

CREATE OR REPLACE VIEW dim_customers AS
SELECT 
    c.customerid,
    c.customername,
    c.email,
	c.age,
    c.gender,
    
    
    g.city,
    g.country
	
FROM customers c
Left JOIN geography g 
    ON c.geographyid = g.geographyid;

--Join view

SELECT * FROM dim_customers;