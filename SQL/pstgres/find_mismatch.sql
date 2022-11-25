\c testingdb
CREATE TABLE source(
id int,
name CHAR(1));
INSERT INTO source
VALUES (1,'A'),
		(2,'B'),
		(3,'C'),
		(4,'D');
CREATE TABLE target(
id int,
name CHAR(1));
INSERT INTO target
VALUES (1,'A'),
		(2,'B'),
		(4,'X'),
		(5,'F');

select * from source;
select * from target;

/*
Find the records in each table that are not in the other as:
	- If in source write New in source.
	- If in target write New in target.
	- If the id in both but not matched write Mismatch.
*/
with unique_source as (
	select id from source
	except
	select id from target),unique_target as(
	select id from target
	except
	select id from source),mis_match as (
	select s.* from source s join target t
	on s.id = t.id where s.name <> t.name)
select id, 'New in source' as Name from unique_source
except
select id, Name from mis_match
union
select id, 'New in target' as Name from unique_target
union
select id, 'Mismatch' as Name from mis_match;

-- =======================================
-- One other way;
with common as (
	select s.id
	from source s inner join target t on s.id=t.id)
select id, 'New in source' as Name from source s
where s.id not in (select * from common)
union
select id, 'New in target' as Name from target t
where t.id not in (select * from common)
union
select s.id, 'Mismatch' from source s
join target t on t.id = s.id
where t.name <> s.name;

-- ========================================
select s.id, 'Mismatch' from source s join target t
on s.id = t.id where s.name <> t.name
	union
select s.id, 'New in source' from source s left join target t
on s.id = t.id where t.id is null
	union
select t.id, 'New in target' from target t left join source s
on s.id = t.id where s.id is null;

drop table source;
drop table target;