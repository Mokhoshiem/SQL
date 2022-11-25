\c testingdb
-- Given the table below;
CREATE TABLE comments(
commentID int,
comment text,
translation text);
INSERT INTO comments(commentID, comment, translation)
VALUES (1,'very good', NULL),
		(2,'good', NULL),
		(3,'bad', NULL),
		(4,'ordinary', NULL),
		(5,'cddcdcd', 'very good'),
		(6,'excellent', NULL),
		(7,'ababab', 'not satisfied'),
		(8,'satisfied', NULL),
		(9,'aabbaabb', 'extraordinary'),
		(10,'ccddccbb', 'medium');
-- extract all meaningful comments;
/* 
We here need to get all comments in meaningful way;
if the comment in not meaningful use the translation to make it meaningful;
*/
SELECT * FROM comments;
-- We can use the coalesce function to get the nulls from translation
-- and replace it with comments, 
-- since it's hard to distinguish the comments.
-- -(if it's translated it's not meaningful.)-
SELECT 
COALESCE(translation, comment) AS meaningful
FROM comments;
--  OR, we can union them;
SELECT comment FROM comments
WHERE translation IS NULL
UNION ALL
SELECT translation FROM comments
WHERE translation IS NOT NULL;
DROP TABLE comments;