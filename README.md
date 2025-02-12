# Netflix Data Analysis Using SQL Project

## Project Overview

**Project Title**: Netflix Data Analysis  
**Level**: Intermediate  
**Database**: `netflix_db`

This project involves analyzing Netflix's dataset using SQL. The dataset contains information about movies and TV shows, including title, director, cast, country, release year, rating, duration, and genre. Various queries are executed to extract insights, perform data exploration, and answer specific business questions.

## Objectives

1. **Database Setup:** Establish a table for storing Netflix content data.
2. **Data Exploration:** Analyze data distribution, content types, and patterns.
3. **Data Analysis:** Perform complex queries to gain insights into Netflix content.
4. **Advanced SQL Queries:** Execute ranking, grouping, and filtering queries for better understanding.

## Tasks and Solutions

### Data Exploration

#### **Task 1: Retrieve Sample Data**
```sql
SELECT *
FROM netflix
LIMIT 5;
```

#### **Task 2: Count Total Records**
```sql
SELECT COUNT(1)
FROM netflix;
```

#### **Task 3: Types of Content on Netflix**
```sql
SELECT DISTINCT(type)
FROM netflix;
```

#### **Task 4: Different Release Years for Content**
```sql
SELECT DISTINCT(release_year)
FROM netflix;
```

#### **Task 5: Count of Each Content Type**
```sql
SELECT type, COUNT(1)
FROM netflix
GROUP BY type;
```

### Data Analysis Questions

#### **Question 1: Count the Number of Movies vs TV Shows**
```sql
SELECT type, COUNT(1)
FROM netflix
GROUP BY type;
```

#### **Question 2: Find the Most Common Rating for Movies and TV Shows**
```sql
SELECT type, rating AS most_common_rating, number_of_ratings
FROM (
    SELECT type, rating, COUNT(*) AS number_of_ratings,
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    GROUP BY type, rating
) AS rating_ranking
WHERE rank = 1;
```

#### **Question 3: List All Movies Released in 2020**
```sql
SELECT *
FROM netflix
WHERE release_year = 2020 AND type = 'Movie';
```

#### **Question 4: Find the Top 5 Countries with the Most Content**
```sql
SELECT country_individual AS country, total_content
FROM (
    SELECT TRIM(UNNEST(string_to_array(country, ','))) AS country_individual, COUNT(1) AS total_content
    FROM netflix
    GROUP BY country_individual
) AS t1
WHERE country_individual IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

#### **Question 5: Identify the Longest Movie on Netflix**
```sql
SELECT title, CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) AS duration_minutes
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;
```

#### **Question 6: Find Content Added in the Last 5 Years**
```sql
SELECT *
FROM netflix
WHERE date_added BETWEEN CURRENT_DATE - INTERVAL '5 years' AND CURRENT_DATE;
```

#### **Question 7: List All Movies/TV Shows by Director 'Rajiv Chilaka'**
```sql
SELECT *
FROM netflix
WHERE director SIMILAR TO '%(Rajiv Chilaka)%';
```

#### **Question 8: List All TV Shows with More Than 5 Seasons**
```sql
SELECT *, CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) AS number_of_seasons
FROM netflix
WHERE type = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) > 5;
```

#### **Question 9: Count the Number of Content Items in Each Genre**
```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre, COUNT(1) AS number_of_content_items
FROM netflix
GROUP BY genre
ORDER BY genre;
```

#### **Question 10: Find the Top 5 Years with the Highest Number of Content Releases in India**
```sql
SELECT EXTRACT(YEAR FROM date_added) AS year, COUNT(1) AS total_releases,
       ROUND(COUNT(1) :: NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country SIMILAR TO '%(India)%'), 2) * 100 AS percent_of_total_releases
FROM netflix
WHERE country SIMILAR TO '%(India)%'
GROUP BY year
ORDER BY percent_of_total_releases DESC
LIMIT 5;
```

#### **Question 11: List All Movies that are Documentaries**
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND listed_in SIMILAR TO '%(Documentaries)%';
```

#### **Question 12: Find All Content Without a Director**
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

#### **Question 13: Count the Number of Movies Actor 'Salman Khan' Appeared in the Last 10 Years**
```sql
SELECT *
FROM netflix
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '10 years')
  AND "cast" SIMILAR TO '%(Salman Khan)%';
```

#### **Question 14: Find the Top 10 Actors with the Most Appearances in Indian Movies**
```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS cast_india, COUNT(1) AS number_of_movies
FROM netflix
WHERE country SIMILAR TO '%(India)%' AND type = 'Movie'
GROUP BY cast_india
ORDER BY number_of_movies DESC
LIMIT 10;
```

#### **Question 15: Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords**
```sql
SELECT CASE
         WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
         ELSE 'Good'
       END AS category, COUNT(1) AS number_of_content
FROM netflix
GROUP BY category;
```

## Conclusion

This project demonstrates the use of SQL for data analysis, covering data exploration, filtering, ranking, and aggregation. The queries provide insights into Netflix content distribution, trends, and other key metrics, helping understand patterns in the dataset. Advanced SQL techniques such as `UNNEST()`, `STRING_TO_ARRAY()`, `RANK()`, and `SIMILAR TO` are applied to efficiently extract insights.

