CREATE TEMPORARY TABLE calc_royalties
SELECT titles.title_id AS Title_ID, authors.au_id AS Author_ID,titles.price, sales.qty, titles.royalty/100,titleauthor.royaltyper / 100 , titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 AS Royalty
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id;

SELECT *
FROM calc_royalties;

CREATE TEMPORARY TABLE agg_royalties
SELECT Title_ID, Author_ID, SUM(Royalty) AS Royalty
FROM calculate_royalties
GROUP BY calculate_royalties.Author_ID ;

SELECT *
FROM agg_royalties;

CREATE TEMPORARY TABLE adv_royalties
SELECT titles.title_id, authors.au_id, titleauthor.royaltyper / 100 , titles.advance, titleauthor.royaltyper /100 * titles.advance AS Advance_agg
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id
GROUP BY authors.au_id, titles.title_id ;

SELECT *
FROM adv_royalties;

CREATE TEMPORARY TABLE aggregate_adv
SELECT title_id, au_id, SUM(Advance_agg) AS Advance
FROM adv_royalties
GROUP BY adv_royalties.au_id ;

SELECT *
FROM aggregate_adv;

SELECT agg_royalties.Author_ID AS Author_ID, agg_royalties.royalty, aggregate_adv.Advance, agg_royalties.royalty + aggregate_adv.Advance AS Total_Royalties
FROM agg_royalties
LEFT JOIN aggregate_adv ON agg_royalties.Author_ID = aggregate_adv.au_id
ORDER BY Total_Royalties DESC
LIMIT 3;

-------------------------------------------------------------

SELECT agg.Author_ID AS Author_ID  , agg.royalty, agg.Advance,  agg.royalty  + agg.Advance AS Total_Royalties
FROM ((SELECT calc_royalties.Title_ID, calc_royalties.Author_ID, SUM(calc_royalties.Royalty) AS Royalty
FROM ( SELECT titles.title_id AS Title_ID, authors.au_id AS Author_ID,titles.price, sales.qty, titles.royalty/100,titleauthor.royaltyper / 100 , titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100 AS Royalty
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id) AS calc_royalties) AS agg_royalties
SELECT Advance FROM (SELECT title_id, au_id, SUM(Advance_agg) AS Advance 
FROM ( SELECT titles.title_id, authors.au_id, titleauthor.royaltyper / 100 , titles.advance, titleauthor.royaltyper /100 * titles.advance AS Advance_agg
FROM authors
INNER JOIN titleauthor ON authors.au_id = titleauthor.au_id
INNER JOIN titles ON titleauthor.title_id = titles.title_id
INNER JOIN sales ON titles.title_id = sales.title_id
GROUP BY authors.au_id, titles.title_id) AS Advance_agg) ) AS agg 
ORDER BY Total_Royalties DESC
LIMIT 3;

---------------------------------------------------------

CREATE TABLE most_profiting_authors
SELECT agg_royalties.Author_ID AS Author_ID, agg_royalties.royalty + aggregate_adv.Advance AS Profits
FROM agg_royalties
LEFT JOIN aggregate_adv ON agg_royalties.Author_ID = aggregate_adv.au_id;