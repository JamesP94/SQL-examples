--4.1--
CREATE TABLE product_summary (
    year INTEGER,
    description TEXT,
    sales NUMERIC
);

--4.2--
INSERT INTO product_summary (year, description, sales)
VALUES 
(2014, 'BANANA Organic', 176818.73),
(2015, 'BANANA Organic', 258541.96),
(2014, 'AVOCADO Hass Organic', 146480.34),
(2014, 'ChickenBreastBoneless/Skinless', 204630.90);

SELECT *
FROM product_summary

--4.3--
UPDATE product_summary
SET year = 2022
WHERE description = 'AVOCADO Hass Organic';

SELECT *
FROM product_summary

--4.4--
DELETE FROM product_summary 
WHERE year = (SELECT MIN(year) FROM product_summary WHERE description = 'BANANA Organic')
AND description = 'BANANA Organic';

SELECT *
FROM product_summary

--4.5--
SELECT 
    departments.department,
    departments.dept_name, 
    SUM(department_date.spend) AS dept_spend
FROM 
    umt-msba.wedge_example.department_date AS department_date
JOIN 
    umt-msba.wedge_example.departments AS departments 
ON 
    department_date.department = departments.department
WHERE 
    EXTRACT(YEAR FROM department_date.date) = 2015
GROUP BY 
    departments.department, departments.dept_name
ORDER BY 
    dept_spend DESC;

--4.6--
SELECT 
    owner_spend_date.card_no, 
    EXTRACT(YEAR FROM owner_spend_date.date) AS year,
    EXTRACT(MONTH FROM owner_spend_date.date) AS month,
    SUM(owner_spend_date.spend) AS spend,
    SUM(owner_spend_date.items) AS items
FROM 
    umt-msba.wedge_example.owner_spend_date AS owner_spend_date
GROUP BY 
    owner_spend_date.card_no, year, month
HAVING 
    spend BETWEEN 750 AND 1250
ORDER BY 
    spend DESC
LIMIT 
    10;


--4.7--
SELECT 
    COUNT(*) AS total_rows_count,
    COUNT(DISTINCT card_no) AS unique_cards_count,
    SUM(total) AS total_spend_amount,
    COUNT(DISTINCT description) AS unique_descriptions_count
FROM 
    umt-msba.transactions.transArchive_201001_201003;

--The total spend amount looks a little weird, it's in scientific notation. I'm not sure why yet.--

--4.8--
SELECT 
    EXTRACT(YEAR FROM datetime) AS transaction_year,
    COUNT(*) AS total_rows_count,
    COUNT(DISTINCT card_no) AS unique_cards_count,
    SUM(total) AS total_spend_amount,
    COUNT(DISTINCT description) AS unique_descriptions_count
FROM 
    umt-msba.transactions.transArchive_201001_201003
GROUP BY 
    transaction_year;


--4.9--
SELECT 
    EXTRACT(YEAR FROM datetime) AS year,
    SUM(total) AS spend,
    COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE FROM datetime) AS STRING), register_no, emp_no, trans_no)) AS transactions,
    SUM(
        CASE 
            WHEN trans_status IN ('V', 'R') THEN -1 
            ELSE 1 
        END
    ) AS items
FROM 
    umt-msba.transactions.transArchive_201001_201003
WHERE 
    department NOT IN (0, 15)
    AND (trans_status IS NULL OR trans_status IN (' ', 'V', 'R'))
GROUP BY 
    year
ORDER BY 
    year;

--4.10--
SELECT 
    EXTRACT(DATE FROM datetime) AS transaction_date,
    EXTRACT(HOUR FROM datetime) AS transaction_hour,
    SUM(total) AS spend,
    COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE FROM datetime) AS STRING), register_no, emp_no, trans_no)) AS transactions,
    SUM(
        CASE 
            WHEN trans_status IN ('V', 'R') THEN -1 
            ELSE 1 
        END
    ) AS items
FROM 
    umt-msba.transactions.transArchive_201001_201003
WHERE 
    department NOT IN (0, 15)