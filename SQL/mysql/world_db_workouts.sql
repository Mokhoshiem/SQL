-- What is the world population given in th database?
USE world;

SELECT SUM(population) AS "world population"
FROM country;

-- #######################################################
-- -- Which country has the largest population?
SELECT code, Name, SurfaceArea, population
FROM country
ORDER BY population DESC
LIMIT 1;
-- Or
SELECT code, Name, SurfaceArea, population
FROM country
WHERE population = (SELECT MAX(population) FROM country);


-- #######################################################
-- -- Most crowded countries
-- crowd = population / aurfaceArea
SELECT Name AS "Most Crowded Countries",(population / surfaceArea) As crowd
FROM country
ORDER BY crowd DESC
LIMIT 10;


-- #######################################################
-- -- SELECT all cities that start with vowels
SELECT DISTINCT Name AS Voweled_cities
FROM city
where Name like 'a%' or Name like 'e%' or Name like 'i%' 
	or Name like 'o%' or Name like 'u%';
-- Another one
SELECT DISTINCT Name
from city
where left(Name,1) IN ('a', 'e', 'i', 'o', 'u');





-- #######################################################
-- -- Cities end with vowels
SELECT DISTINCT Name AS End_Voweled_cities
FROM city
where Name like '%a' or Name like '%e' or Name like '%i' 
	or Name like '%o' or Name like '%u';
Better one
SELECT DISTINCT Name
from city
where right(Name,1) IN ('a', 'e', 'i', 'o', 'u');



-- #######################################################
-- -- Starts and ends with vowels
SELECT DISTINCT Name AS Start_End_Voweled_cities
FROM city
where (Name like '%a' or Name like '%e' or Name like '%i' 
	or Name like '%o' or Name like '%u') AND (Name like 'a%' or Name like 'e%' or Name like 'i%' 
	or Name like 'o%' or Name like 'u%');
Better solution
SELECT DISTINCT Name
from city
where left(Name,1) IN ('a', 'e', 'i', 'o', 'u') 
	AND right(Name,1) IN ('a', 'e', 'i', 'o', 'u') ;




-- #######################################################
-- -- Neither start or end with vowels
SELECT DISTINCT Name As Not_voweled_cities
FROM city
WHERE NOT Name IN (SELECT DISTINCT Name AS Start_End_Voweled_cities
					FROM city -- sub query to list those start and end with vowels
					where (Name like '%a' or Name like '%e' or Name like '%i' 
						or Name like '%o' or Name like '%u') 
						AND (Name like 'a%' or Name like 'e%' or Name like 'i%' 
						or Name like 'o%' or Name like 'u%'));
-- The best
SELECT DISTINCT Name
FROM city
WHERE NOT Name IN (SELECT DISTINCT Name
from city
where left(Name,1) IN ('a', 'e', 'i', 'o', 'u') 
	AND right(Name,1) IN ('a', 'e', 'i', 'o', 'u'));
-- using UNION
SELECT DISTINCT Name FROM city
WHERE NOT LEFT(Name,1) IN ('a','e','i','o','u')
UNION 
SELECT DISTINCT Name FROM city
WHERE NOT RIGHT(Name,1) IN ('a','e','i','o','u');






--  ===========================================
-- -- HOW MANY LANGUAGES EACH COUNTRY SPEAK?
SELECT c.Name, COUNT(l.countryCode) languageNumber
from country c
LEFT JOIN countryLanguage l
ON c.code = l.countryCode
GROUP by c.Name
ORDER BY languageNumber DESC;
-----------------------------------------------------

--  What are the top 5 used language?
SELECT language, COUNT(language) languageRange
FROM countryLanguage
GROUP BY language
ORDER BY languageRange desc
LIMIT 5;








-- --  ============================================
-- -- Creating a view of the countries population:

CREATE VIEW populationView AS (
SELECT country.Name AS countryName,country.Code AS countryCode,
	IFNULL(SUM(city.population),0) AS totalPopulation
FROM country
LEFT JOIN city
ON country.Code = city.CountryCode
GROUP BY country.code
ORDER BY totalPopulation DESC);

-- -- POPULATION BY CONTINENT
SELECT c.continent, SUM(pv.totalPopulation) AS population
FROM country c
JOIN populationView pv
ON c.Name = pv.countryName
GROUP BY c.continent
ORDER BY population DESC;

--  HOW MANY CITIES IN EACH CONTINENT?
SELECT c.continent, COUNT(city.Name) 'CityNumber'
FROM country c
LEFT JOIN city
ON c.code = city.countryCode
GROUP BY c.continent
ORDER BY CityNumber DESC;

-- -- AVERAGE POPULATION PR CITY IN EACH CONTINENT?

SELECT cp.continent, (cp.population / cn.CityNumber) AS AVG_city_population
FROM (SELECT c.continent AS continent, SUM(pv.totalPopulation) AS population
	FROM country c
	JOIN populationView pv
	ON c.Name = pv.countryName
	GROUP BY c.continent
	ORDER BY population DESC) cp
JOIN (SELECT c.continent, IFNULL(COUNT(city.Name),0) 'CityNumber'
	FROM country c
	LEFT JOIN city
	ON c.code = city.countryCode
	GROUP BY c.continent
	ORDER BY CityNumber DESC) cn
ON cp.continent = cn.continent;

