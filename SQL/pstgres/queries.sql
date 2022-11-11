-- =================================================
-- customers table (customerID, customerName, phoneNumber, city)
-- invoices table (invoiceID, customer, total, date)
\c testingdb
-- query the third customer total from each city
-- WITH data AS (
-- 	SELECT c.customerID, SUM(i.total) total, c.city,
-- 			ROW_NUMBER() OVER(PARTITION BY c.city) rn
-- 	FROM customers c
-- 	JOIN invoices i
-- 	ON c.customerID = i.customer
-- 	GROUP BY c.customerID)
-- SELECT *
-- FROM data d
-- WHERE d.rn = 3
-- ORDER BY d.customerID;

-- what is the max, min spend for each city and for all?
-- to find the top two spend customers of each city
WITH data AS (
	SELECT c.customerID, SUM(i.total) total, c.city,
		ROW_NUMBER() OVER() AS abs_rn,
		ROW_NUMBER() OVER(PARTITION BY c.city) AS city_rn
	FROM customers c
	JOIN invoices i
	ON c.customerID = i.customer
	GROUP BY c.customerID
	ORDER BY c.city, total DESC)
SELECT d.customerID, d.city,d.total,
		MAX(d.total) OVER() AS abs_max,
		MAX(d.total) OVER(PARTITION BY d.city) AS city_max,
		MIN(d.total) OVER() AS abs_min,
		MIN(d.total) OVER(PARTITION BY d.city) AS city_min
FROM data d
WHERE d.city_rn < 3;

-- to find the least two spend customers of each city
WITH data AS (
	SELECT c.customerID, SUM(i.total) total, c.city,
		ROW_NUMBER() OVER() AS abs_rn,
		ROW_NUMBER() OVER(PARTITION BY c.city) AS city_rn
	FROM customers c
	JOIN invoices i
	ON c.customerID = i.customer
	GROUP BY c.customerID
	ORDER BY c.city, total)
SELECT d.customerID, d.city,d.total,
		MAX(d.total) OVER() AS abs_max,
		MAX(d.total) OVER(PARTITION BY d.city) AS city_max,
		MIN(d.total) OVER() AS abs_min,
		MIN(d.total) OVER(PARTITION BY d.city) AS city_min
FROM data d
WHERE d.city_rn < 3;