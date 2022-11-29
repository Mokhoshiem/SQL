use world;
-- Fetch all cities from city table in Africa.

-- select c.name
-- from city c
-- join country cou
-- on c.countryCode = cou.code
-- where continent = 'Africa';

-- ==============================================================

/*
Given the CITY and COUNTRY tables, 
query the names of all the continents (COUNTRY.Continent) and 
their respective average city populations (CITY.Population) 
rounded down to the nearest integer.
Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
*/
select cou.continent, floor(avg(c.population))
from city c
join country cou on c.countryCode = cou.code
group by cou.continent;

-- ==============================================================

/*
You are given two tables: Students and Grades. 
Students contains three columns ID, Name and Marks.
Grades contains the following data:
Grade, Min_mark, Max_mark
Ketty gives Eve a task to generate a report containing three columns: 
Name, Grade and Mark. 
Ketty doesn't want the NAMES of those students who received a grade 
lower than 8. 
The report must be in descending order by grade 
-- i.e. higher grades are entered first. 
If there is more than one student with the same grade (8-10) 
assigned to them, order those particular students by their name 
alphabetically. Finally, if the grade is lower than 8, 
use "NULL" as their name and list them by their grades in descending 
order. If there is more than one student with the same grade (1-7) 
assigned to them, order those particular students by their marks 
in ascending order.

Write a query to help Eve.
*/
select case 
    when g.grade >= 8 then s.name else null end as name
    , g.grade, s.marks 
from students s join grades g
on (s.marks >= g.min_mark and s.marks <= g.max_mark)
order by g.grade desc, s.name;

-- ==================================================

