SELECT 	Subscription_Type, count("Subscription_Type") AS count
FROM netflix_users
GROUP BY Subscription_Type
ORDER BY count DESC;

SELECT Subscription_Type,
AVG(Watch_Time_Hours) AS watch_time
FROM netflix_users
group by Subscription_Type
order by watch_time DESC;

SELECT Country, COUNT(Name) AS COUNT
FROM netflix_users
GROUP BY Country
ORDER BY COUNT Desc;

SELECT Country, AVG(Watch_Time_Hours) AS Watch_Time
FROM netflix_users
group by Country
ORDER BY Watch_Time DESC;

WITH age_groups AS (
SELECT 
	CASE 
		WHEN `Age` < 18 THEN 'Teen'
		WHEN `Age` BETWEEN 18 AND 25 THEN 'Young Adult'
		WHEN `Age` BETWEEN 26 AND 35 THEN 'Adult'
		WHEN `Age` BETWEEN 36 AND 45 THEN 'Mid Age'
		WHEN `Age` BETWEEN 46 AND 60 THEN 'Young Senior'
		WHEN `Age` > 50 THEN 'Senior'
	END AS `age group`
FROM netflix_users
	)
SELECT `age group`, COUNT(`age group`) AS `count`
FROM age_groups
GROUP BY `age group`
ORDER BY `count` DESC;

SELECT Favorite_Genre, COUNT(`Favorite_Genre`) AS `count`
FROM netflix_users
group by `Favorite_Genre`
order by `count` DESC