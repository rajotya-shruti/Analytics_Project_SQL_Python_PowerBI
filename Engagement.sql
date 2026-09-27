SELECT * FROM engagement_data;

--Create the fact_engagement_data View

CREATE OR REPLACE VIEW fact_engagement_data AS
SELECT 
    engagementid,
    contentid,
    campaignid,
    productid,
    
    -- Formatting engagement date type
    TO_CHAR(CAST(engagementdate AS DATE), 'DD-MM-YYYY') AS engagement_date,
    
    -- Standardizing Content Types: Using UPPER() for uniform spelling and uppercase formatting
    UPPER(contenttype) AS content_type,
    
    -- Splitting 'Views-Clicks' into two separate integer columns
    CAST(SPLIT_PART(viewsclickscombined, '-', 1) AS integer) AS views,
    CAST(SPLIT_PART(viewsclickscombined, '-', 2) AS integer) AS clicks,
    
    likes
FROM engagement_data
-- Data Filtering: Removing 'Newsletter' entries so only relevant marketing rows pass to Power BI
WHERE UPPER(contenttype) != 'NEWSLETTER';

SELECT * FROM fact_engagement_data;
