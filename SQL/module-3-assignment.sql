--3.1--
CREATE TEMPORARY TABLE owner_year_month AS
SELECT 
    card_no,
    strftime('%Y', date) AS year,
    strftime('%m', date) AS month,
    SUM(spend) AS spend,
    SUM(items) AS items
FROM 
    owner_spend_date
GROUP BY 
    card_no, 
    strftime('%Y', date),
    strftime('%m', date);

	
--3.2--
SELECT 
    year,
    month,
    SUM(spend) AS total_spend
FROM 
    owner_year_month
GROUP BY 
    year,
    month
ORDER BY 
    total_spend DESC
LIMIT 5;

--3.3--
SELECT 
    month,
    ROUND(AVG(spend), 2) AS avg_spend
FROM 
    owner_year_month
WHERE 
    card_no IN (
        SELECT card_no 
        FROM owners 
        WHERE zip = '55405'
    )
GROUP BY 
    month
ORDER BY 
    month;
	
--3.4--
SELECT 
    o.zip,
    ROUND(SUM(oym.spend), 2) AS total_spend
FROM 
    owners o
JOIN 
    owner_year_month oym ON o.card_no = oym.card_no
GROUP BY 
    o.zip
ORDER BY 
    total_spend DESC
LIMIT 3;

--3.5--
WITH
-- CTE for 55405 zip code--
avg_spend_55405 AS (
    SELECT 
        month,
        ROUND(AVG(spend), 2) AS avg_spend
    FROM 
        owner_year_month oym
    WHERE 
        card_no IN (SELECT card_no FROM owners WHERE zip = '55405')
    GROUP BY 
        month
),
-- CTE for 55305 zip code--
avg_spend_55305 AS (
    SELECT 
        month,
        ROUND(AVG(spend), 2) AS avg_spend
    FROM 
        owner_year_month oym
    WHERE 
        card_no IN (SELECT card_no FROM owners WHERE zip = '55305')
    GROUP BY 
        month
),
-- CTE for 55116 zip code--
avg_spend_55116 AS (
    SELECT 
        month,
        ROUND(AVG(spend), 2) AS avg_spend
    FROM 
        owner_year_month oym
    WHERE 
        card_no IN (SELECT card_no FROM owners WHERE zip = '55116')
    GROUP BY 
        month
)
-- Main Query to join the CTEs--
SELECT 
    a1.month,
    a1.avg_spend AS avg_spend_55405,
    a2.avg_spend AS avg_spend_55305,
    a3.avg_spend AS avg_spend_55116
FROM 
    avg_spend_55405 a1
LEFT JOIN 
    avg_spend_55305 a2 ON a1.month = a2.month
LEFT JOIN 
    avg_spend_55116 a3 ON a1.month = a3.month
ORDER BY 
    a1.month;
	
--3.6--
-- Delete the temporary table if it exists
DROP TABLE IF EXISTS owner_year_month;

-- Create the temporary table
CREATE TEMPORARY TABLE owner_year_month AS
SELECT 
    card_no,
    strftime('%Y', date) AS year,
    strftime('%m', date) AS month,
    SUM(spend) AS spend,
    SUM(items) AS items
FROM 
    owner_spend_date
GROUP BY 
    card_no, 
    strftime('%Y', date),
    strftime('%m', date);

-- CTE to calculate the total spend for each owner
WITH total_spend_cte AS (
    SELECT 
        card_no,
        SUM(spend) AS total_spend
    FROM 
        owner_year_month
    GROUP BY 
        card_no
)

-- Main Query to join the CTE with owner_year_month table
SELECT 
    oym.card_no,
    oym.year,
    oym.month,
    oym.spend,
    tsc.total_spend
FROM 
    owner_year_month oym
JOIN 
    total_spend_cte tsc ON oym.card_no = tsc.card_no
ORDER BY 
    oym.card_no, oym.year, oym.month;
	
-- Run this after rebuilding your temporary table.--
SELECT COUNT(DISTINCT(card_no)) AS owners,
 COUNT(DISTINCT(year)) AS years,
 COUNT(DISTINCT(month)) AS months,
 ROUND(AVG(spend),2) AS avg_spend,
 ROUND(AVG(items),1) AS avg_items,
 ROUND(SUM(spend)/SUM(items),2) AS avg_item_price
FROM owner_year_month 

--3.7--
DROP VIEW IF EXISTS vw_owner_recent;

CREATE VIEW vw_owner_recent AS
SELECT 
    card_no,
    SUM(spend) AS total_spend,
    AVG(spend) AS avg_spend_per_transaction,
    COUNT(DISTINCT date) AS number_of_shopping_dates,
    COUNT(*) AS total_trans,
    strftime('%Y-%m-%d', MAX(date)) AS last_visit
FROM 
    owner_spend_date
GROUP BY 
    card_no;
	
SELECT COUNT(DISTINCT card_no) AS owners,
 ROUND(SUM(total_spend)/1000,1) AS spend_k
FROM vw_owner_recent
WHERE 5 < total_trans AND
 total_trans < 25 AND
 SUBSTR(last_visit,1,4) IN ('2016','2017')
 
 --3.8--
 -- Drop the owner_recent table if it exists
DROP TABLE IF EXISTS owner_recent;

-- Create the owner_recent table
CREATE TABLE owner_recent AS
SELECT 
    v.*,
    osd.spend AS last_spend
FROM 
    vw_owner_recent v
JOIN 
    owner_spend_date osd ON v.card_no = osd.card_no AND v.last_visit = strftime('%Y-%m-%d', osd.date);

--Query 1--
-- Select a row from the table
SELECT *
FROM owner_recent
WHERE card_no = "18736"; 

--Query 2--
-- Select a row from the view
SELECT *
FROM vw_owner_recent
WHERE card_no = "18736"; 

--1. What is the time difference between the two versions of the query?--
--The second query was 3745ms longer than the first query--

--2. Why do you think this difference exists?--
--The query using the table is faster because the query using the view has--
--to iterate over the sql code held in the view, while the table query only--
--has to run the code from the query--

--3.9--
SELECT *
FROM owner_recent
WHERE 
    last_spend < 0.5 * avg_spend_per_transaction AND
    total_spend >= 5000 AND
    number_of_shopping_dates >= 270 AND
    last_visit <= '2016-12-02' AND
    last_spend > 10
ORDER BY 
    (avg_spend_per_transaction - last_spend) DESC, 
    total_spend DESC;
	
--3.10--
SELECT 
    orec.*,
    o.zip AS owner_zip_code
FROM 
    owner_recent orec
JOIN 
    owners o ON orec.card_no = o.card_no
WHERE 
    -- Criteria 1: Non-null, non-blank zips and not in Wedge or adjacent zip codes
    o.zip IS NOT NULL AND 
    o.zip != '' AND 
    o.zip NOT IN ('55405', '55442', '55416', '55408', '55404', '55403') AND
    
    -- Criteria 2: Last spend less than half their average spend
    orec.last_spend < 0.5 * orec.avg_spend_per_transaction AND
    
    -- Criteria 3: Total spend at least $5,000
    orec.total_spend >= 5000 AND
    
    -- Criteria 4: At least 100 shopping dates
    orec.number_of_shopping_dates >= 100 AND
    
    -- Criteria 5: Last visit at least 60 days before 2017-01-31
    orec.last_visit <= '2016-12-02' AND
    
    -- Criteria 6: Last spend over $10
    orec.last_spend > 10
ORDER BY 
    (orec.avg_spend_per_transaction - orec.last_spend) DESC, 
    orec.total_spend DESC;