--5.1--
SELECT SUM(spend) AS total_spend_by_all_owners
FROM owner_spend_date;

--5.2--
SELECT card_no, MAX(spend) AS max_spend
FROM owner_spend_date
WHERE card_no != 3
AND strftime('%Y', date) = '2017'
GROUP BY card_no
HAVING SUM(spend) > 10000
ORDER BY max_spend DESC;

--5.3--
SELECT *
FROM department_date
WHERE department NOT IN (1, 2)
AND spend BETWEEN 5000 AND 7500
AND strftime('%m', date) IN ('05', '06', '07', '08') -- Assuming date in 'YYYY-MM-DD' format
ORDER BY spend DESC;

--5.4--
WITH BusyMonths AS (
    SELECT strftime('%Y', date) AS year, strftime('%m', date) AS month, SUM(spend) AS total_store_spend
    FROM date_hour
    GROUP BY year, month
    ORDER BY total_store_spend DESC
    LIMIT 4
)

SELECT b.year, b.month, b.total_store_spend, d.department, SUM(d.spend) AS department_spend
FROM BusyMonths b
JOIN department_date d ON strftime('%Y', d.date) = b.year AND strftime('%m', d.date) = b.month
GROUP BY b.year, b.month, d.department
HAVING department_spend > 200000
ORDER BY b.year ASC, b.month ASC, department_spend DESC;

--5.5--
WITH ZipSpend AS (
    SELECT o.zip, 
           COUNT(DISTINCT o.card_no) AS number_of_owners, 
           SUM(s.spend) / COUNT(DISTINCT o.card_no) AS avg_spend_per_owner,
           SUM(s.spend) / SUM(s.trans) AS avg_spend_per_transaction
    FROM owners o
    JOIN owner_spend_date s ON o.card_no = s.card_no
    GROUP BY o.zip
    HAVING number_of_owners >= 100
)

SELECT zip, 
       number_of_owners, 
       avg_spend_per_owner, 
       avg_spend_per_transaction
FROM ZipSpend
ORDER BY avg_spend_per_transaction DESC
LIMIT 5;

--5.6--
WITH ZipSpend AS (
    SELECT o.zip, 
           COUNT(DISTINCT o.card_no) AS number_of_owners, 
           SUM(s.spend) / COUNT(DISTINCT o.card_no) AS avg_spend_per_owner,
           SUM(s.spend) / SUM(s.trans) AS avg_spend_per_transaction
    FROM owners o
    JOIN owner_spend_date s ON o.card_no = s.card_no
    WHERE o.zip IS NOT NULL AND o.zip != ''
    GROUP BY o.zip
    HAVING number_of_owners >= 100
)

SELECT zip, 
       number_of_owners, 
       avg_spend_per_owner, 
       avg_spend_per_transaction
FROM ZipSpend
ORDER BY avg_spend_per_transaction ASC
LIMIT 5;

--5.7--
SELECT zip, 
       SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_owners,
       SUM(CASE WHEN status != 'active' THEN 1 ELSE 0 END) AS inactive_owners,
       CAST(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS REAL) / COUNT(*) AS fraction_active
FROM owners
GROUP BY zip
HAVING COUNT(*) >= 50
ORDER BY COUNT(*) DESC;

--5.8--
import sqlite3

--Connect to the database (it will create the file if it doesn't exist)
conn = sqlite3.connect('owner_prod.db')
cursor = conn.cursor()

--Create the table
cursor.execute('''
CREATE TABLE owner_products (
    owner INTEGER,
    upc INTEGER,
    description TEXT,
    dept_name TEXT,
    spend NUMERIC,
    items INTEGER,
    trans INTEGER
)
''')

conn.commit()
conn.close()


--5.9--
# Insert the data into the table
cursor.executemany('''
INSERT INTO owner_products (owner, upc, description, dept_name, spend, items, trans)
VALUES (?, ?, ?, ?, ?, ?, ?)
''', owner_prod)

# Commit the changes and close the connection
conn.commit()
conn.close()

# Return a success message
"Table created and data from owner_products.txt has been successfully inserted into the owner_products table!"

--5.10--
query = '''
SELECT description, dept_name, SUM(spend) as total_spend
FROM owner_products
WHERE dept_name LIKE '%groc%'
GROUP BY description, dept_name
ORDER BY total_spend DESC
LIMIT 10;
'''

cursor.execute(query)

# Fetch the results and print the first 10 rows
results = cursor.fetchall()
for row in results:
    print(row)

# Close the connection
conn.close()