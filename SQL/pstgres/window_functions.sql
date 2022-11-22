\c testingdb


-- ----------------ROW_NUMBER()----------------------------
/*  
ROW_NUBER() adds a unique number for each record and can be used to track the record as identifier:
If we don't specify a column in the OVER(), it will be general window.
But we usually want to split the window using the OVER(PARTITION BY column_name ORDER BY column_name) 
Clause as;
In general use it to extract nth record of some data like:
	Ex: find the 2nd top spend customers of each city
*/
WITH data AS(
	SELECT ts.*, ROW_NUMBER() OVER(PARTITION BY ts.city ORDER BY ts.total DESC) rn
	FROM total_spendings ts)
SELECT * FROM data d
WHERE d.rn = 2;

to find the 4th least spend customers of each city
WITH data AS(
	SELECT ts.*, ROW_NUMBER() OVER(PARTITION BY ts.city ORDER BY ts.total) rn
	FROM total_spendings ts)
SELECT * FROM data d
WHERE d.rn = 4;


-- ----------------RANK()----------------------------
/*
RANK() is also a common window function used for ranking the records;
*/
--  Fetch the first top 3 total spend records of each city.
WITH data AS (
	SELECT ts.*, RANK() OVER(PARTITION BY ts.city ORDER BY ts.total DESC) AS rnk
	FROM total_spendings ts)
SELECT * FROM data d
WHERE d.rnk < 4;

--  Fetch the first least 3 total spend records of each city.
WITH data AS (
	SELECT ts.*, RANK() OVER(PARTITION BY ts.city ORDER BY ts.total) AS rnk
	FROM total_spendings ts)
SELECT * FROM data d
WHERE d.rnk < 4;

-- ------------------DENSE_RANK()------------------------
/*
DENSE_RANK() is like rank but, if there is a tie or two equal values RANK() will give the both 
the same rank whether DENSE_RANK() will give them sam rank but won't skip a value.
*/
WITH data AS (
	SELECT ts.*, RANK() OVER(PARTITION BY ts.city ORDER BY ts.total DESC) AS rnk,
		DENSE_RANK() OVER(PARTITION BY ts.city ORDER BY ts.total DESC) AS dns_rnk
	FROM total_spendings ts)
SELECT * FROM data d
WHERE dns_rnk < 3;

-- ----------------------LAG(column_nam, [how many rows prev.], [default value if null]) -------
/*
If you want to get the value of the previous record then, use lag
*/
SELECT ts.*,
	LAG(ts.total,2) OVER(PARTITION BY ts.city ORDER BY ts.city) AS prev_total
FROM total_spendings ts;

--  -------------------LEAD()_______________________________
/*
LEAD() is unlike LAG(), returns the next record
*/
SELECT * FROM(
 	SELECT ts.*,
	LAG(ts.total) OVER(PARTITION BY ts.city ORDER BY ts.city) AS prev_total,
	LEAD(ts.total) OVER(PARTITION BY ts.city ORDER BY ts.city) AS next_total
FROM total_spendings ts) t
WHERE t.prev_total < t.next_total;

-- Fetch the difference in total between each customer and the previous customer in Alexandria;
WITH alex_totals AS (
	SELECT *,
	COALESCE ((total - LAG(total) OVER(PARTITION BY city ORDER BY total)),0) AS difference,
	CAST(((total - LAG(total) OVER(PARTITION BY city ORDER BY total)) / LAG(total) OVER(PARTITION BY city ORDER BY total))*100 AS NUMERIC(10,2)) AS percentage,
	ROW_NUMBER() OVER(PARTITION BY city ORDER BY total) As rn
	FROM total_spendings
) 
SELECT at.customerID, at.city, at.total, at.difference, at.percentage, at.rn
FROM alex_totals at
WHERE at.city = 'Alexandria';

-- ------------------FIRST_VALUE()-----------------------
/*
FIRST_VALUE() fetches the first value of records correspoding to a specific
criteria and windows it as a new column.
*/
-- Here we fetch only the top spending customers;
SELECT ts.city,MAX(ts.total)
FROM total_spendings ts
GROUP BY ts.city
ORDER BY ts.city;

WITH ts_data AS(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY city ORDER BY total DESC) AS rnk
	FROM total_spendings)
SELECT city, total FROM ts_data
WHERE ts_data.rnk = 1;
-- But here we window the most spending customer for each city;
SELECT *,FIRST_VALUE(customerID) OVER(PARTITION BY city ORDER BY total DESC) AS top_client
FROM total_spendings;

-- ---------------LAST_VALUE()--------------------
/*
Unlike FIRST_VALUE(), LAST_VALUE() function windows the last value of
the data retrieved 
*/
Fetch the least spending customer;
SELECT ts.city,MIN(ts.total)
FROM total_spendings ts
GROUP BY ts.city
ORDER BY ts.city;

WITH ts_data AS(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY city ORDER BY total) AS rnk
	FROM total_spendings)
SELECT city, total FROM ts_data
WHERE ts_data.rnk = 1;
-- But here we window the least spending customer for each city;
SELECT *,
LAST_VALUE(customerID) 
OVER(PARTITION BY city ORDER BY total DESC /*Write the frame clause here*/
range between unbounded preceding and unbounded following) AS least_client
FROM total_spendings;

 --  Using WINDOW to reduce redundency;
 /*
 Place it right after the where clause and before order by clause
 */
 SELECT *,
 		FIRST_VALUE(customerID) OVER w AS Most_spend,
 		LAST_VALUE(customerID) OVER w AS least_spend
 FROM total_spendings
 WINDOW w AS(PARTITION BY city ORDER BY total DESC range between unbounded preceding and unbounded following);

-- -----------------------NTH_VALUE()--------------------
/*
Like first_value and last_value funcions nth_value fetches the nth value of a window
it accepts two parameters NTH_VALUE(column, position -nth-)
*/
-- Fetch the third most spend customer of each city;
WITH data AS(
	SELECT *,
			ROW_NUMBER() OVER(PARTITION BY city ORDER BY total DESC) AS rn
	FROM total_spendings)
SELECT d.customerID, d.total, d.city
FROM data d
WHERE rn = 3;

-- -- Now show the third most spend customer along with the data set
SELECT d.*
FROM(SELECT *,
		NTH_VALUE(customerID, 3) OVER(PARTITION BY city ORDER BY total DESC) AS third_customer
		FROM total_spendings) d
WHERE d.customerID = third_customer;


-- --------------------NTILE()-----------------------------
/*
NTILE() function is used for dividing the data set into n buckets
It takes one arguement the number of buckets or bins to be divided into
In the over clause we can skip the partionion by and just use order by column
But this has a con, it tries to divide the set into equal buckets in number regardless the value
*/
-- Divide all customers in Alexandria to equal parts high spend, mid spend, low spend
SELECT c.customerID,
		CASE 
		WHEN c.nt = 1 THEN 'High'
		WHEN c.nt = 2 THEN 'Mid'
		WHEN c.nt = 3 THEN 'Low'
		ELSE ''
		END AS customer_category
FROM (
	SELECT *, NTILE(3) OVER(ORDER BY total DESC) AS nt
	FROM total_spendings
	WHERE city = 'Alexandria'
	) c;


--  -------------------CUME_DIST()---------------
/*
The cume_dist function divides the row number by the total row numbers
ex:total rows = 100
then first row in the cume_dist is 1/100 = .01,
second row is 2/100 = .02,
row number 70 is 70/100 =.7 etc....
*/
SELECT *,
		CUME_DIST() OVER(ORDER BY total DESC) AS cume_distance
FROM total_spendings;

-- Fetch the first 30 percent of customers who represent top 30% of customers
-- Old way

SELECT *
FROM(
	SELECT *,
			ROUND((ROW_NUMBER() OVER(ORDER BY total DESC))*1.0/(SELECT COUNT(customerID) FROM total_spendings)*1.0,2) AS r_per
	FROM total_spendings) d
WHERE d.r_per <=.3;

-- -- With cume_dist() function
SELECT *
FROM(
	SELECT *,
		CUME_DIST() OVER(ORDER BY total DESC) AS cume_distance
	FROM total_spendings) x
WHERE x.cume_distance <=.3;

-- What if we want to know the top customers who form 30% of total sales?
-- This one I will do in separate commit using python.`KB