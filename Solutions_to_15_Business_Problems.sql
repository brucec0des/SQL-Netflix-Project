-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT
	type,  
	COUNT(*) as total_titles
FROM
	netflix
GROUP BY 
	type;




-- 2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating,
	rating_count
FROM
(
SELECT
	type,
	rating,
	COUNT (*) as rating_count,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM
	netflix
GROUP BY
	type, rating
ORDER BY
	type, rating_count DESC
) AS t1
WHERE ranking = 1;




--3. List all movies released in a specific year (e.g., 2020)
SELECT
	title,
	release_year
FROM
	netflix
WHERE
	type = 'Movie' AND release_year = 2020
ORDER BY
	title ASC;
	



4. Find the top 5 countries with the most content on Netflix
SELECT 
	TRIM(UNNEST((STRING_TO_ARRAY(country, ',')))) AS new_country,
	COUNT(show_id) AS num_of_content
FROM 
	netflix
GROUP BY
	new_country
ORDER BY
	num_of_content DESC
LIMIT 5
;




--5. Identify the longest movie
SELECT
	type,
	title,
	CAST(TRIM(' min' FROM duration) AS INT) AS runtime
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY runtime DESC
LIMIT 1
;




--6. Find content added in the last 5 years
SELECT 
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS';




--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	*
FROM
	netflix
WHERE
	director LIKE '%Rajiv Chilaka%'
ORDER BY
	title;




--8. List all TV shows with more than 5 seasons
SELECT
	*
FROM netflix
WHERE 
	type = 'TV Show' AND CAST(TRIM(' Seasons' FROM duration) AS INT) > 5;




--9. Count the number of content items in each genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,', ')) as new_genres,
	COUNT (show_id) AS genre_count
FROM
	netflix
GROUP BY
	new_genres
ORDER BY
	genre_count DESC;




--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
SELECT 
	release_year,
	COUNT(*) AS total_releases,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS average_indian_releases
FROM
	netflix
GROUP BY
	release_year
ORDER BY
	average_indian_releases DESC
LIMIT 5;




--11. List all movies that are documentaries
SELECT 
	* 
FROM 
	netflix 
WHERE
	type = 'Movie' AND listed_in iLIKE '%docu%'
ORDER BY
	title;




--12. Find all content without a director
SELECT * FROM netflix WHERE director IS NULL




--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT 
	* 
FROM 
	netflix 
WHERE 
	type = 'Movie' AND casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;




--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	UNNEST(STRING_TO_ARRAY(casts,', ')) AS new_actors,
	COUNT(*) AS totals
FROM
	netflix
WHERE
	type = 'Movie' AND country ILIKE '%India%'
GROUP BY
	new_actors
ORDER BY
	totals DESC
LIMIT 10;




--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT
	*,
	CASE
	WHEN 
		description ILIKE 'kill%' OR description ILIKE '%violen%' THEN 'Bad'
		ELSE 'Good'
	END category
FROM 
	netflix
)
SELECT
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY category