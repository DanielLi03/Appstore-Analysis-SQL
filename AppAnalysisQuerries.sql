CREATE TABLE appleCombined AS 

SELECT * FROM appleStore_description1 

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL 

SELECT * FROM appleStore_description4;

-- EDA --

-- check number of unique apps match

SELECT COUNT(DISTINCT id) as UniqueAppID
FROM AppleStore;

SELECT COUNT(DISTINCT id) AS UniqueAppID
FROM appleCombined;

-- check for missigness --

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL or price IS NULL;

SELECT COUNT(*) AS MissingValues
FROM appleCombined
WHERE track_name IS null;

-- Let's Look at the distribution of genres --

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC;

-- Games is by far the most popular, followed by Entertainment and Education

-- Let's look at an overview of Rating --

SELECT min(user_rating) as MinRating, 
	max(user_rating) as MaxRating, avg(user_rating) AS AvgRating
FROM AppleStore;

-- Now we can look at a distribution of the ratings -- 

SELECT user_rating, COUNT(*) as RatingCount
FROM AppleStore
GROUP BY user_rating;

-- It's important to note that on the App store, users can give a rating from 1-5 stars incremented by 0.5
-- However, we see a bunch of 0 stars, indicating that these are actually users_ratings where the user didn't
-- rate the app. We'll keep this in mind for future investigation

-- Let's look at an overiew of the price of the apps --

SELECT min(price) as MinPrice, 
	max(price) as MaxPrice, avg(price) AS AvgPrice
FROM AppleStore;

-- Let's look at a distribution of the price --

select 
    case 
        when price <= 0 then 'Free' 
        when price between 0 and 5 then 'Low'
        WHEN price BETWEEN 5 and 20 THEN 'Mid'
        WHEN price > 20 THEN 'High'
    end as PriceCategory, 
    count(*) 
from AppleStore
group by PriceCategory; 

-- This is about what we'd expect (free apps being more common, with lower frequency the higher the price).

-- what about device number --

ALTER TABLE AppleStore RENAME COLUMN sup_devices_num TO sup_devs;

SELECT min(sup_devs) as Minsup_devs, 
	max(sup_devs) as Maxsup_devs, avg(sup_devs) AS Avgsup_devs
FROM AppleStore;

-- Let's look at a distribution of this --

select 
    case 
        when sup_devs <= 20 then 'Low' 
        when sup_devs between 20 and 29 then 'Midlow'
        WHEN sup_devs BETWEEN 29 and 38 THEN 'Midhigh'
        WHEN sup_devs > 38 THEN 'High'
    end as sup_devs_buckets, 
    count(*) 
from AppleStore
group by sup_devs_buckets;

-- Most apps support a "MidHigh", or > 29, devices

-- finally let's look at lang_num --

SELECT min(lang_num) as Minlang_num, 
	max(lang_num) as Maxlang_num, avg(lang_num) AS Avglang_num
FROM AppleStore;

-- and for the distribution --

select 
    case 
        when lang_num <= 10 then 'Low' 
        when lang_num between 10 and 30 then 'Mid'
        WHEN lang_num > 30 THEN 'High'
    end as lang_num_buckets, 
    count(*) 
from AppleStore
group by lang_num_buckets;

-- Most apps support less than 10 langauges --

-- Now let's do some Data Analysis to generate some insights --

-- Let's see what the relationship between genre and ratings is

SELECT prime_genre, avg(nullif(user_rating, 0)) as AvgRating
FROM AppleStore
GROUP BY prime_genre
ORDER BY AvgRating DESC

-- Seems like Sports apps have the lowest ratings nad Book apps have the higher rating
-- In this regard we could interpret the results in two ways: Build a sports app because there aren't
-- as many good sports app so we capitalize on that, or build a book app because the target audience is
-- more forgiving in terms of ratings so our app is less likely to tank

-- What should we price our app?

select 
    case 
        when price <= 0 then 'Free' 
        when price between 0 and 5 then 'Low'
        WHEN price BETWEEN 5 and 20 THEN 'Mid'
        WHEN price > 20 THEN 'High'
    end as PriceCategory, 
    avg(user_rating) as AvgRating
from AppleStore
group by PriceCategory; 

-- looks like paid apps have the highest rating, with the optimal price being between 0 and 5.
-- Again there are two interpretations: Paid apps have a higher rating because the user expects 
-- more from the app and it seems that paid apps delivered on the most part. Or, you should build
-- a free app because people have less expecation. Whatever the case, I would heavily suggest
-- pricing the app on the cheaper side, and going for a 0-5 price model for maximum rating.

-- Is there a correlation between app desciption and user rating?

SELECT 
	CASE
		WHEN length(B.app_desc) < 500 THEN 'Short'
        WHEN length(B.app_desc) BETWEEN 500 AND 1500 THEN 'Mid'
        ELSE 'Long'
    END AS AppDescLength,
    avg(user_rating) AS AvgRating
FROM AppleStore As A
JOIN appleCombined AS B
ON A.id = B.id
GROUP BY AppDescLength;

-- The longer the app description the higher the rating. This is probably because app description length
-- speaks to how much effort the app creator put into the app yielding a higher quality product.
-- Whatever the case, I would writing a longer app description to maximize ratings (ideally more thatn 1500 characters)

-- Now let's look at the relationships between device supported and ratings

select 
    case 
        when sup_devs <= 20 then 'Low' 
        when sup_devs between 20 and 29 then 'Midlow'
        WHEN sup_devs BETWEEN 29 and 38 THEN 'Midhigh'
        WHEN sup_devs > 38 THEN 'High'
    end as sup_devs_buckets, 
    avg(user_rating) as AvgRating 
from AppleStore
group by sup_devs_buckets;

-- Surprisingly, the lower the number of supported devices, the higher the average rating of the app
-- This could suggest that app creators spent more time compatabilizing the app with each device
-- yielding better user experience. The takeaway is to cater your app to less devices.

select 
    case 
        when lang_num <= 10 then 'Low' 
        when lang_num between 10 and 30 then 'Mid'
        WHEN lang_num > 30 THEN 'High'
    end as lang_num_buckets, 
    avg(user_rating) as AvgRating
from AppleStore
group by lang_num_buckets;

-- Apps supporting 10-30 languages seem to be the highest rated. 

