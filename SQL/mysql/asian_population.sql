use world;
select sum(p.population)
from
(select cou.code,sum(c.population) as population
from city c
join country cou on c.countryCode = cou.code
where cou.continent = 'Asia'
group by cou.code) p;