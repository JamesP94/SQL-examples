--2.1--
SELECT 
    department_date.department, 
    departments.department, 
    SUM(department_date.spend) AS "Department Spend"
FROM department_date
JOIN departments ON department_date.department = departments.department
GROUP BY department_date.department, departments.department
ORDER BY "Department Spend" DESC;

--2.2--
SELECT 
    department_date.department, 
    departments.department, 
    SUM(department_date.spend) AS "Department Spend"
FROM department_date
JOIN departments ON department_date.department = departments.department
WHERE strftime('%Y', department_date.date) = '2015'
GROUP BY department_date.department, departments.department
ORDER BY "Department Spend" DESC;

--2.3--
SELECT 
    strftime('%Y', date) AS year, 
    COUNT(DISTINCT card_no) AS num_owners, 
    SUM(spend) AS total_spend
FROM owner_spend_date
GROUP BY year
ORDER BY year;

--2.4--
SELECT 
    hour, 
    COUNT(*) AS "Num Days", 
    ROUND(SUM(spend), 2) AS "Total Sales"
FROM date_hour
GROUP BY hour
ORDER BY hour;

--2.5--
SELECT 
    hour, 
    COUNT(*) AS "Num Days", 
    ROUND(SUM(spend), 2) AS "Total Sales"
FROM date_hour
GROUP BY hour
HAVING COUNT(*) < 2570
ORDER BY hour;

--2.6--
SELECT 
	owner_spend_date.card_no, 
    COUNT(DISTINCT owner_spend_date.date) AS "Num Days", 
    SUM(owner_spend_date.spend) AS "Total Spend"
FROM owner_spend_date
GROUP BY owner_spend_date.card_no
ORDER BY "Total Spend" DESC;

--2.7--
SELECT 
    owner_spend_date.card_no, 
    COUNT(DISTINCT owner_spend_date.date) AS "Num Days", 
    SUM(owner_spend_date.spend) AS "Total Spend",
    ROUND(SUM(owner_spend_date.spend) / COUNT(DISTINCT owner_spend_date.date), 2) AS "Average Daily Spend"
FROM owner_spend_date
GROUP BY owner_spend_date.card_no
ORDER BY "Average Daily Spend" DESC;

--2.8--
SELECT 
    owners.zip,
    COUNT(DISTINCT owner_spend_date.date) AS "Num Owner-Days", 
    ROUND(SUM(owner_spend_date.spend), 2) AS "Total Spend",
    ROUND(SUM(owner_spend_date.spend) / COUNT(DISTINCT owner_spend_date.date), 2) AS "Average Daily Spend"
FROM owner_spend_date
JOIN owners ON owner_spend_date.card_no = owners.card_no
GROUP BY owners.zip
ORDER BY "Total Spend" DESC;

--2.9--
SELECT
    CASE
        WHEN owners.zip = '55405' THEN 'wedge'
        WHEN owners.zip IN ('55442', '55416', '55408', '55404', '55403') THEN 'adjacent'
        ELSE 'other'
    END AS Area,
    COUNT(DISTINCT owner_spend_date.card_no) AS "Number of Owners",
    COUNT(*) AS "Number of Owner-Days",
    ROUND(CAST(COUNT(*) AS REAL) / COUNT(DISTINCT owner_spend_date.card_no), 2) AS "Average Number of Days per Owner",
    SUM(owner_spend_date.spend) AS "Total Spend",
    ROUND(SUM(owner_spend_date.spend) / COUNT(DISTINCT owner_spend_date.card_no), 2) AS "Average Spend per Owner",
    ROUND(SUM(owner_spend_date.spend) / COUNT(*), 2) AS "Average Spend per Owner Day"
FROM
    owner_spend_date
JOIN owners ON owner_spend_date.card_no = owners.card_no
GROUP BY Area
ORDER BY
    CASE 
        WHEN Area = 'wedge' THEN 1
        WHEN Area = 'adjacent' THEN 2
        ELSE 3
    END;

--2.10--
SELECT 
    department_date.department AS "Department Number",
    departments.dept_name AS "Department Name",
    ROUND(SUM(department_date.spend)) AS "Total Spend",
    SUM(department_date.items) AS "Total Number of Items Purchased",
    COUNT(DISTINCT department_date.trans) AS "Total Number of Transactions",
    ROUND(SUM(department_date.spend) / NULLIF(SUM(department_date.items), 0), 2) AS "Average Item Price"
FROM department_date
JOIN departments ON department_date.department = departments.department
GROUP BY department_date.department, departments.dept_name
ORDER BY "Average Item Price" DESC;


