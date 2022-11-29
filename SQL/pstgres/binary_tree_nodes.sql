\c testingdb
/*
You are given a table BST. It has two columns N and P
N represents the value in binary tree, and P is the parent of N 
*/
create table bst(
	N int,
	P int);
	
insert into bst
	values(1,2),(3,2),(6,8),(9,8),(2,5),(8,5),(5,null);

/* 
Write a query to find the node type of Binary Tree ordered by the value of the node.
Output one of the following for each node:
	Root: If node is root node. -- has no parent
	Leaf: If node is leaf node. -- has no children
	Inner: If node is neither root nor leaf node. 
*/
select * from bst;

with roots as(
	select N, 'Root' as flag
	from bst
	where P is null),inners as(
	select N, 'Inner' as flag
	from bst 
	where N in (select P from bst) and N not in (select N from bst where P is null)
	)
select bst.N, re.flag
from bst
join (
	select * from roots
	union 
	select * from inners
	union
	select N, 'Leaf' as flag
	from bst 
	where N not in (select N from roots) and N not in (select N from inners)
	) re
on bst.N = re.N
order by bst.N;


drop table bst;