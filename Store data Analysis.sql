-- Q1.Who is the senior most employee based on job title?

SELECT *
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1 -- Q2.which countries has the most invoices?

SELECT *
FROM INVOICE
SELECT COUNT(*),
	BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY COUNT(*) DESC ;

-- Q3. What are top 3 values of invoice.

SELECT TOTAL AS
VALUES
FROM INVOICE
ORDER BY
VALUES DESC
LIMIT 3 -- Q4. which city has the best customers?
 -- we would like to throw a promotional music festival in the city
 -- that has the highest sum of invoice totals.
 -- return both city name and sum of all invoice totals.

SELECT BILLING_CITY,
	SUM(TOTAL) AS INVOICE_TOTALS
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTALS DESC -- Q5. Who is the best customer?
 -- the customer who has spent the most money be declared the best customer.
 -- write a query that return the person has spent the most money.

SELECT *
FROM INVOICE
SELECT *
FROM CUSTOMER
SELECT C.CUSTOMER_ID,
	CONCAT(C.FIRST_NAME,

		C.LAST_NAME),
	SUM(I.TOTAL) AS TOTAL
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1 -- Q6. Write query to return the email, first_name, last_name
 -- and genre of all the rock music listners.
 -- return your list ordered alphabetically  by email starting with A.

SELECT *
FROM GENRE
SELECT *
FROM CUSTOMER
SELECT *
FROM PLAYLIST_TRACK
SELECT *
FROM TRACK
SELECT *
FROM INVOICE_LINE
SELECT DISTINCT EMAIL,
	FIRST_NAME,
	LAST_NAME
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
WHERE TRACK_ID IN
		(SELECT T.TRACK_ID
			FROM TRACK T
			JOIN GENRE AS G ON G.GENRE_ID = T.GENRE_ID
			WHERE G.NAME like 'Rock')
ORDER BY EMAIL ASC -- Q7. Let's invite the artists who have written the most rock music 
 -- in our dataset. 
 -- write a query that returns the artist name 
 -- and total track count of the top 10 rock bands.
 
SELECT ARTIST.ARTIST_ID, 
	ARTIST.NAME, 
	COUNT(ARTIST.ARTIST_ID) AS TOTAL_SONGS 
FROM TRACK 
JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID 
JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID 
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID 
WHERE GENRE.NAME like 'Rock'
GROUP BY ARTIST.ARTIST_ID
ORDER BY TOTAL_SONGS DESC
LIMIT 10;

-- Q8. Return all the track names that have
 -- a song length longer than the average song length.
 -- return the name and millseconds for each track.
 -- order by the song length with the longest song listed first.

SELECT NAME,
	MILLISECONDS
FROM TRACK
WHERE MILLISECONDS >
		(SELECT AVG(MILLISECONDS) AS TRACK_LENGTH
			FROM TRACK)
ORDER BY MILLISECONDS DESC;

-- Q.9 Find how much amount spend by each customer on artist?
 -- write a query to return customer name, artist,name and total spent
 WITH BEST_SELLING_ARTIST AS
	(SELECT ARTIST.ARTIST_ID AS ARTIST_ID,
			ARTIST.NAME AS ARTIST_NAME,
			SUM(INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL_SALES
		FROM INVOICE_LINE
		JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
		JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
		JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
		GROUP BY 1
		ORDER BY 3 DESC
		LIMIT 1)
SELECT C.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	BSA.ARTIST_NAME,
	SUM(IL.UNIT_PRICE * IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE AS IL ON IL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM AL ON AL.ALBUM_ID = T.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID = AL.ARTIST_ID
GROUP BY 1,2,
	3,4
ORDER BY 5 DESC;

-- Q9. we want to find out the most popular music genre for each country
 -- we determine the most popular genre as the genre with the highest amount of purchases.
 -- write a query that return each country along with the top genre.
 -- for countries where the maximum number of purchases is shared return all genres.
 WITH POPULAR_GENRE AS
	(SELECT COUNT (INVOICE_LINE.QUANTITY) AS PURCHASES,
			CUSTOMER.COUNTRY,
			GENRE.GENRE_ID,
			GENRE.NAME,
			ROW_NUMBER() OVER(PARTITION BY CUSTOMER.COUNTRY
																					ORDER BY COUNT (INVOICE_LINE.QUANTITY) DESC) AS ROWNO
		FROM INVOICE_LINE
		JOIN INVOICE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
		JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
		JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
		JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
		GROUP BY 2,3,
			4
		ORDER BY 2 ASC, 1 DESC)
SELECT *
FROM POPULAR_GENRE
WHERE ROWNO <= 1 -- Q10. Write a query that determines the customer that has spent the most on music for each country.
 -- write a query that returns the country along with the top customer and how much they spent.
 -- for countries where the top amount spent is shared, provide all customers who spent this amount
 WITH RECURSIVE CUSTOMER_WITH_COUNTRY AS
		(SELECT CUSTOMER.CUSTOMER_ID,
				FIRST_NAME,
				LAST_NAME,
				BILLING_COUNTRY,
				SUM(TOTAL) AS TOTAL_SPENDING
			FROM INVOICE
			JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
			GROUP BY 1,2,
				3,4
			ORDER BY 2,3 DESC),
		COUNTRY_MAX_SPENDING AS
		(SELECT BILLING_COUNTRY,
				MAX(TOTAL_SPENDING) AS MAX_SPENDING
			FROM CUSTOMER_WITH_COUNTRY
			GROUP BY BILLING_COUNTRY)
	SELECT CC.BILLING_COUNTRY,
		CC.TOTAL_SPENDING,
		CC.FIRST_NAME,
		CC.LAST_NAME,
		CC.CUSTOMER_ID
	FROM CUSTOMER_WITH_COUNTRY CC
	JOIN COUNTRY_MAX_SPENDING MS ON CC.BILLING_COUNTRY = MS.BILLING_COUNTRY WHERE CC.TOTAL_SPENDING = MS.MAX_SPENDING
ORDER BY 1;