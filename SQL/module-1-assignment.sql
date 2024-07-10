--1.1--
SELECT 
    SUM(spend) AS "Total Spend",
    SUM(trans) AS "Total Transactions",
    SUM(items) AS "Total Items"
FROM 
    date_hour;

--1.2--
SELECT 
    date, 
    SUM(spend) AS "Daily Spend"
FROM 
    date_hour
GROUP BY 
    date
ORDER BY 
    "Daily Spend" DESC
LIMIT 
    5;

	
--1.3--
SELECT 
    date, 
    SUM(spend) AS "Daily Spend"
FROM 
    date_hour
GROUP BY 
    date
ORDER BY 
    "Daily Spend" ASC
LIMIT 
    5;
	
--1.4--
SELECT 
    date, 
    hour, 
    spend
FROM 
    date_hour
ORDER BY CAST
    (spend AS REAL) DESC
LIMIT 
    3;

--1.5--
SELECT 
    department,
    SUM(spend) AS "Department Spend"
FROM 
    department_date
GROUP BY 
    department
ORDER BY 
    "Department Spend" DESC;
	
--1.6--
SELECT 
    department,
    SUM(spend) AS "Department Spend"
FROM 
    department_date
WHERE
    strftime('%Y', date) = '2015'
GROUP BY 
    department
ORDER BY 
    "Department Spend" DESC;
	
--1.7--
SELECT 
    date,
    spend
FROM 
    department_date
WHERE
    department = 6
ORDER BY 
    spend DESC
LIMIT 
    10;

--1.8--
SELECT 
    date,
    spend
FROM 
    department_date
WHERE
    department = 8
ORDER BY 
    spend DESC
LIMIT 
    10;
	
--1.9--
SELECT 
    strftime('%m', date) AS month,
    SUM(spend) AS spend
FROM 
    owner_spend_date
WHERE
    card_no = 18736
GROUP BY 
    strftime('%m', date)
ORDER BY 
    month ASC;

--1.10--
SELECT 
    strftime('%Y', date) AS year,
    strftime('%m', date) AS month,
    SUM(spend) AS spend
FROM 
    owner_spend_date
WHERE
    card_no = 18736
GROUP BY 
    strftime('%Y', date), strftime('%m', date)
ORDER BY 
    year ASC, month ASC;






