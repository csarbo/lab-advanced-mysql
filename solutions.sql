CREATE TEMPORARY TABLE calculate_royalties
SELECT titles.title_id AS Title_ID, authors.au_id AS Author_ID, titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 AS Royalty
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id;

CREATE TEMPORARY TABLE aggregate_royalties
SELECT Title_ID, Author_ID, SUM(Royalty) AS Royalty
FROM calculate_royalties
GROUP BY calculate_royalties.Title_ID , calculate_royalties.Author_ID ;

SELECT aggregate_royalties.Author_ID, titles.advance + aggregate_royalties.Royalty AS Royalties
FROM aggregate_royalties 
INNER JOIN titles ON aggregate_royalties.Title_ID = titles.title_id
ORDER BY Royalties DESC
LIMIT 3;

-------------------------------------------------------------

SELECT titles.title_id AS Title_ID, authors.au_id AS Author_ID, SUM(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS Royalty
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id
GROUP BY Title_ID , Author_ID;

# ME FALTA HACER EL TERCER PASO EN UN SUBQUERY