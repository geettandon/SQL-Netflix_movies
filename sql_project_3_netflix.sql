-- Creating table netflix
CREATE TABLE netflix (
	show_id		VARCHAR(10),
	type		VARCHAR(20),
	title		VARCHAR(200),
	director	VARCHAR(250),
	"cast"		VARCHAR(1000),
	country		VARCHAR(200),
	date_added	DATE,
	release_year	INT,
	rating		VARCHAR(20),
	duration	VARCHAR(20),
	listed_in	VARCHAR(100),
	description	VARCHAR(300)
);

-- Query the table
SELECT *
FROM netflix
LIMIT 5;

-- Query number of rows
SELECT COUNT(1)
FROM netflix;

-- Data Exploration

-- Types of content
SELECT DISTINCT(type)
FROM netflix;

--  Different release year for content
SELECT DISTINCT(release_year)
FROM netflix;

-- Different rating content
SELECT DISTINCT(rating)
FROM netflix;

-- Count of type
SELECT type,
	COUNT(1)
FROM netflix
GROUP BY type;

-- Director with number of directions
SELECT UNNEST(string_to_array(director, ', ')) AS individual_directors,
	COUNT(1) AS number_of_directions
FROM netflix
GROUP BY individual_directors
ORDER BY number_of_directions DESC;

-- Director with number of directions in different titles type
SELECT type,
	UNNEST(string_to_array(director, ', ')) AS individual_directors,
	COUNT(1) AS number_of_directions
FROM netflix
GROUP BY individual_directors, type
ORDER BY number_of_directions DESC;

-- cast with number of work
SELECT UNNEST(string_to_array("cast", ', ')) AS individual_cast,
	COUNT(1) AS number_of_work
FROM netflix
GROUP BY individual_cast
ORDER BY number_of_work DESC;

-- cast worked in different type of titles
SELECT type,
	UNNEST(string_to_array("cast", ', ')) AS individual_cast,
	COUNT(1) AS number_of_work
FROM netflix
GROUP BY type, individual_cast
ORDER BY individual_cast ASC, type;

-- titles by Country
SELECT TRIM(UNNEST(string_to_array(country, ','))) AS country, 
	COUNT(1) AS number_of_titles
FROM netflix
GROUP BY country
ORDER BY number_of_titles DESC;

-- titles by Country and type
SELECT type,
	UNNEST(string_to_array(country, ', ')) AS country, 
	COUNT(1) AS number_of_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY type, country
ORDER BY country, type;

-- titles by rating 
SELECT rating,
	COUNT(1) AS number_of_titles
FROM netflix
GROUP BY rating
ORDER BY number_of_titles DESC;

-- Count by release year
SELECT release_year,
	COUNT(1)
FROM netflix
GROUP BY release_year
ORDER BY COUNT(1) DESC;

-- titles by category listed_in
SELECT UNNEST(string_to_array(listed_in, ', ')) AS category,
	COUNT(1) AS number_of_titles
FROM netflix
GROUP BY category
ORDER BY number_of_titles DESC;


-- Questions

-- 1. Count the Number of Movies vs TV Shows
-- Objective: Determine the distribution of content types on Netflix.
SELECT type,
	COUNT(1)
FROM netflix
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows
-- Objective: Identify the most frequently occurring rating for each type of content.
SELECT
	type,
	rating AS most_common_rating,
	number_of_ratings
	
FROM (
	SELECT type,
		rating,
	COUNT(*) AS number_of_ratings,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
	FROM netflix
	GROUP BY type, rating
	) AS rating_ranking
WHERE rank = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
-- Objective: Retrieve all movies released in a specific year.
SELECT *
FROM netflix
WHERE release_year = 2020
	AND type = 'Movie';

-- 4. Find the Top 5 Countries with the Most Content on Netflix
-- Objective: Identify the top 5 countries with the highest number of content items.
SELECT country_individual AS country,
	total_content
FROM (
	SELECT TRIM(UNNEST(string_to_array(country, ','))) AS country_individual,
		COUNT(1) AS total_content
	FROM netflix
	GROUP BY country_individual
	) AS t1
WHERE country_individual IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the Longest Movie
-- Objective: Find the movie with the longest duration.
SELECT title,
	--CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS NUMERIC) AS duration_minutes,
	CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) AS duration_minutes
FROM netflix
WHERE type = 'Movie'
	AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;

-- 6. Find Content Added in the Last 5 Years
-- Objective: Retrieve content added to Netflix in the last 5 years.
SELECT * 
FROM netflix
WHERE date_added BETWEEN CURRENT_DATE - INTERVAL '5 years' AND CURRENT_DATE;

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
-- Objective: List all content directed by 'Rajiv Chilaka'.
SELECT * 
FROM netflix
WHERE director SIMILAR TO '%(Rajiv Chilaka)%';

-- 8. List All TV Shows with More Than 5 Seasons
-- Objective: Identify TV shows with more than 5 seasons.
SELECT *,
	CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) AS number_of_seasons
FROM netflix
WHERE type = 'TV Show'
	AND CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) > 5

-- 9. Count the Number of Content Items in Each Genre
-- Objective: Count the number of content items in each genre.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(1) AS number_of_content_items
FROM netflix
GROUP BY genre
ORDER BY genre;

-- 10. Find each year and the highest numbers of content release in India on netflix.
-- Objective: Calculate and rank years by the highest number of content releases by India.
-- return top 5 year with highest avg content release!
SELECT EXTRACT(YEAR FROM date_added) AS year,
	COUNT(1) AS total_releases,
	ROUND(COUNT(1) :: NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country SIMILAR TO '%(India)%'), 2) * 100 AS percent_of_total_releases
FROM netflix
WHERE country SIMILAR TO '%(India)%'
GROUP BY year
ORDER BY percent_of_total_releases DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
-- Objective: Retrieve all movies classified as documentaries.
SELECT * 
FROM netflix
WHERE type = 'Movie'
	AND listed_in SIMILAR TO '%(Documentaries)%';

-- 12. Find All Content Without a Director
-- Objective: List content that does not have a director.
SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
-- Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.
SELECT *
FROM netflix
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE- INTERVAL '10 years')
	AND "cast" SIMILAR TO '%(Salman Khan)%'

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
-- Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.
SELECT TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS cast_india,
	COUNT(1) AS number_of_movies
FROM netflix
WHERE country SIMILAR TO '%(India)%'
	AND type = 'Movie'
GROUP BY cast_india
ORDER BY number_of_movies DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
-- Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
-- Count the number of items in each category.
SELECT 
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS category,
	COUNT(1) AS number_of_content
FROM netflix
GROUP BY category;