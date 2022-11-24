\c testingdb
create table if not exists duplicates(
	rowID int,
	id int,
	brand varchar(100),
	model varchar(150),
	price numeric(8,2));
insert into duplicates(rowID,id, brand, model, price)
	values(1,1,'Apple','Mac bro6',1000.25),
	(2,2,'Apple','Apple watch As235',1206),
	(3,1,'Apple','Mac bro6',1000.25),
	(4,3,'Samsung','Samsung EA14',465.75),
	(5,2,'Apple','Apple watch As235',1206),
	(6,1,'Apple','Mac bro6',1000.25),
	(7,3,'Samsung','Samsung EA14',465.75);

-- select * from duplicates;

/*
To remove duplicates, we must have a unique identifier which is
in this case the rowID;
*/
with dup_vals AS(
	select *,
	row_number() over(partition by (id,brand,model,price) order by id) as rn
	from duplicates)
delete from duplicates
	where rowID not in (select rowID from dup_vals where rn < 2);
select * from duplicates;
delete from duplicates;
drop table duplicates;