

-- # Checked all the datatype of columns present in the table 

DESCRIBE credit_card_transactions;
SELECT * FROM credit_card_transactions ;

-- # Made changes in the datatype according to the data present in the column

-- ALTER TABLE credit_card_transcations
-- MODIFY COLUMN transaction_id INT,
-- MODIFY COLUMN city VARCHAR(100),
-- MODIFY COLUMN card_type VARCHAR(50),
-- MODIFY COLUMN exp_type VARCHAR(50),
-- MODIFY COLUMN gender VARCHAR(10),
-- MODIFY COLUMN amount DECIMAL(10,2);


-- ALTER TABLE credit_card_transcations ADD COLUMN new_date DATE ;

-- UPDATE credit_card_transcations
-- SET new_date = STR_TO_DATE(transaction_date, '%d-%b-%y');

-- USE Credit_card_sql_project;

-- RENAME TABLE credit_card_transcations TO credit_card_transactions;

ALTER TABLE credit_card_transactions
DROP COLUMN transaction_date;

ALTER TABLE credit_card_transactions
CHANGE COLUMN new_date transaction_date DATE;


# Data Cleaning and Featuring processes are done....

#EDA 

SELECT *
FROM credit_card_transactions;

SELECT DISTINCT card_type 
FROM credit_card_transactions;

SELECT DISTINCT exp_type
FROM credit_card_transactions;


-- Que1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends

SELECT
city,
SUM(amount) as total_spend,
ROUND((SUM(amount) / (SELECT SUM(amount) FROM credit_card_transactions)) * 100,2) as perc_contribution
FROM credit_card_transactions
GROUP BY city ORDER BY total_spend DESC LIMIT 10;



-- Que2- write a query to print highest spend month and amount spent in that month for each card type

WITH monthly_spend AS (SELECT 
    card_type,
    MONTHNAME(transaction_date) AS month,
    SUM(amount) AS total_spent
FROM credit_card_transactions
GROUP BY card_type, MONTH(transaction_date), MONTHNAME(transaction_date))

SELECT
m.card_type, m.month, m.total_spent
FROM monthly_spend m
JOIN (
	SELECT card_type, MAX(total_spent) AS max_spent
    FROM monthly_spend
    GROUP BY card_type
) t
ON m.card_type = t.card_type AND m.total_spent = t.max_spent
ORDER BY m.card_type;


-- Que3. write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with trans_details AS (SELECT *,
RANK() OVER(PARTITION BY card_type ORDER BY cum_sum) AS rnk FROM (SELECT * ,
SUM(amount) OVER(PARTITION BY card_type ORDER BY transaction_date,transaction_id) AS cum_sum
FROM credit_card_transactions
ORDER BY card_type, transaction_date, transaction_id) A 
WHERE cum_sum >= 1000000)

SELECT transaction_id, city, card_type, exp_type, gender, amount, transaction_date, cum_sum
FROM trans_details 
WHERE rnk = 1;


-- Que4- write a query to find city which had lowest percentage spend for gold card type

SELECT
city,
card_type,
(SUM(amount) / (SELECT SUM(amount) FROM credit_card_transactions) * 100) as amt
FROM credit_card_transactions
WHERE card_type = 'Gold'
GROUP BY city
ORDER BY amt LIMIT 1;



-- Que5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

WITH total_spend_cte AS (SELECT 
city,
exp_type,
SUM(amount) as total_spend
FROM credit_card_transactions
GROUP BY city, exp_type
),
rnk as (
SELECT *,
RANK() OVER(PARTITION BY city ORDER BY total_spend DESC) rn_high,
RANK() OVER(PARTITION BY city ORDER BY total_spend) rn_low
FROM
total_spend_cte)


SELECT city,
MAX(CASE WHEN rn_high = 1 THEN exp_type END) AS highest_expense_type,
MAX(CASE WHEN rn_low = 1 THEN exp_type END) AS lowest_expense_type
FROM rnk
WHERE rn_high = 1 or rn_low = 1 
GROUP BY city
;



-- Que6. write a query to find percentage contribution of spends by females for each expense type

SELECT 
exp_type,
SUM(amount) total_spend,
SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) AS female_spend,
SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) / SUM(amount) * 100 AS female_contribution
FROM credit_card_transactions
GROUP BY exp_type
ORDER BY female_contribution DESC;


-- Que7- which card and expense type combination saw highest month over month growth in Jan-2014
WITH cte AS (
SELECT card_type,exp_type,YEAR(transaction_date) yt
,MONTH(transaction_date) mt,sum(amount) as total_spend
FROM credit_card_transactions
GROUP BY card_type,exp_type,YEAR(transaction_date),MONTH(transaction_date)
)
SELECT *, (total_spend-prev_mont_spend) as mom_growth
FROM (
SELECT *
,LAG(total_spend,1) OVER(PARTITION BY card_type,exp_type ORDER BY yt,mt) AS prev_mont_spend
FROM cte) A
WHERE prev_mont_spend IS NOT NULL AND yt=2014 AND mt=1
ORDER BY mom_growth DESC LIMIT 1;


-- Que8. during weekends which city has highest total spend to total no of transcations ratio 

SELECT city, SUM(amount) / COUNT(*) as ratio
FROM credit_card_transactions 
WHERE WEEKDAY(transaction_date) in (1,7)
GROUP BY city
ORDER BY ratio DESC;










