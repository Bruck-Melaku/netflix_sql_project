# Netflix Movies and TV Shows Data Analysis using SQL



## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6), 
	type VARCHAR(10), 
	title VARCHAR(150), 
	director VARCHAR(210), 
	casts VARCHAR(1000), 
	country VARCHAR(150), 
	date_added DATE, 
	release_year INT, 
	rating VARCHAR(10), 
	duration VARCHAR(15), 
	listed_in VARCHAR(100), 
	description VARCHAR(250)
)
;
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(type) AS Total_no_of_types
FROM netflix
GROUP by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV show' AND (CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >5);
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT TRIM(j.genre) AS genre,
       COUNT(*) AS total_content
FROM netflix n
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.listed_in, ',', '","'), '"]'),
    '$[*]' COLUMNS (genre VARCHAR(255) PATH '$')
) AS j
GROUP BY TRIM(j.genre)
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
	release_year, 
    COUNT(release_year) AS No_content_release,
    COUNT(release_year)/ (SELECT COUNT(release_year) FROM netflix WHERE country LIKE '%India%') * 100 AS AVG_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 1;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE 
	type = 'Movie'
    AND
    listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director = '';
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE
	type = 'Movie'
    AND casts LIKE '%Salman Khan%'
    AND release_year >= YEAR(CURDATE()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Bruck Melaku

## Author's Notes - I would like to thank ZeroAnalyst for guidance in the data analysis.



- **YouTube**: [Subscribe to my channel for tutorials and insights](https://www.youtube.com/@zero_analyst)
- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/zero_analyst/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)
- **Discord**: [Join our community to learn and grow together](https://discord.gg/36h5f2Z5PK)

Thank you for your support, and I look forward to connecting with you!
