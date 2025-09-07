-- Count the Number of Movies vs TV Shows
SELECT type, COUNT(type) AS Total_no_of_types
FROM netflix
GROUP by type;

-- Find the Most Common Rating for Movies and TV Shows
SELECT
	type,
    rating
FROM
(SELECT 
	type, 
    rating, 
    COUNt(*) AS Total_No_of_ratings,
    RANK() OVER (PARTITION BY type ORDER BY COUNt(*) DESC) AS ranking
FROM netflix
GROUP BY 1, 2) AS t1
WHERE ranking = 1;

-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

-- Find the Top 5 Countries with the Most Content on Netflix
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(j.country) AS country
    FROM netflix n,
    JSON_TABLE(
        CONCAT('["', REPLACE(n.country, ',', '","'), '"]'),
        '$[*]' COLUMNS (country VARCHAR(150) PATH '$')
    ) AS j
) AS t1
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

--  Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);


-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV show' AND (CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >5);

-- Count the Number of Content Items in Each Genre
SELECT TRIM(j.genre) AS genre,
       COUNT(*) AS total_content
FROM netflix n
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
    '$[*]' COLUMNS (genre VARCHAR(255) PATH '$')
) AS j
GROUP BY TRIM(j.genre)
ORDER BY total_content DESC;


-- Find each year and the average numbers of content release in India on netflix.
SELECT 
	release_year, 
    COUNT(release_year) AS No_content_release,
    COUNT(release_year)/ (SELECT COUNT(release_year) FROM netflix WHERE country LIKE '%India%') * 100 AS AVG_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 1;

-- List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
    AND
    listed_in LIKE '%Documentaries%';
    
-- Find All Content Without a Director
SELECT *
FROM netflix
WHERE director = '';

-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT *
FROM netflix
WHERE
	type = 'Movie'
    AND casts LIKE '%Salman Khan%'
    AND release_year >= YEAR(CURDATE()) - 10; 
    
-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    TRIM(j.actor) AS actor,
    COUNT(*) AS movie_count
FROM netflix n
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.casts, ',', '","'), '"]'),
    '$[*]' COLUMNS (actor VARCHAR(255) PATH '$')
) AS j
WHERE n.type = 'Movie'
  AND n.country LIKE '%India%'
  AND n.casts IS NOT NULL
GROUP BY TRIM(j.actor)
ORDER BY movie_count DESC
LIMIT 10;

-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
	category, 
    COUNT(*) AS content_count
FROM (
	SELECT 
    show_id,
    title,
    description,
    CASE
        WHEN description LIKE '%kill%' AND description LIKE '%violence%' THEN 'Contains Kill & Violence'
        WHEN description LIKE '%kill%' THEN 'Contains Kill'
        WHEN description LIKE '%violence%' THEN 'Contains Violence'
        ELSE 'No Keywords'
    END AS category
FROM netflix) AS Categorized_content
GROUP BY 1
;

    
    



