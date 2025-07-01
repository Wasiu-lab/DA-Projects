-- QUESTION 1: 
-- Find the number of businesses in each category 
select trim(A.value) as category, count(business_id)
from tbl_yelp_business,
lateral split_to_table(categories, ',') A
group by category
order by 2 desc;

--  the above can also be written using cte 
with cte as (
select trim(A.value) as category, business_id
from tbl_yelp_business,
lateral split_to_table(categories, ',') A
)
select category, count(*) as no_of_biz
from cte 
group by 1
order by 2 desc

-- QUESTION 2:
-- Find the top 10 users who have reviewed the most businesses in the restaurant category

select r.user_id, count(distinct (r.business_id)) as top_most_reviewed_rest
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
where b.categories ilike '%restaurant%'
group by 1
order by 2 desc
limit 10;

-- QUESTION 3:
-- Find the most popular categories of businesses (based on the number of reviews)

with cte as (
select trim(A.value) as category, business_id
from tbl_yelp_business,
lateral split_to_table(categories, ',') A
) 
select category, count(*) as number_of_review
from cte inner join tbl_yelp_review r 
on cte.business_id = r.business_id
group by 1
order by 2 desc
limit 10

-- QUESTION 4:
-- Find the top 3 most recent reviews for each business.

with cte as (
select r.*, b.name,
row_number() over (partition by r.business_id order by review_date desc) as rn 
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
)
select * 
from cte
where rn <=3;

-- QUESTION 5:
-- Find the month with the highest number of reviews.
select month(review_date) as review_month, count(*) as no_of_reviews
from tbl_yelp_review
group by 1
order by 2 desc
limit 1;

-- QUESTION 6:
-- Find the percentage of 5-star reviews for each business.

select b.business_id, b.name, count(*) as total_review,
sum(case when r.review_stars = 5 then 1 else 0 end) as five_star_reviews,
(five_star_reviews*100)/total_review as percent_5_star
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
group by 1,2;


-- QUESTION 7:
-- Find the top five most reviewed businesses in each city.

with cte as (
select b.city, b.business_id, b.name, count(*) as total_review,
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
group by 1,2,3)
select *
from cte
qualify row_number() over (partition by city order by total_review desc) <=5

-- QUESTION 8:
-- Find the average rating of businesses that have at least 100 reviews

select b.business_id, b.name, count(*) as total_review,
avg(review_stars) as average_rating
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
group by 1,2
having total_review >= 100

-- QUESTION 9:
-- List the top 10 users who have written the most reviews, along with the business they reviewed
-- QUERY 1
-- Step 1: Identify the top 10 users who have written the most reviews overall.
-- Step 2: For each of these users, list the businesses they reviewed along with the business name.
-- This version uses JOINs and includes more descriptive information for reporting or dashboarding.


WITH top_users AS (
  SELECT r.user_id, COUNT(*) AS total_review
  FROM tbl_yelp_review r
  INNER JOIN tbl_yelp_business b 
    ON r.business_id = b.business_id
  GROUP BY r.user_id
  ORDER BY total_review DESC
  LIMIT 10
)
SELECT  
  r.user_id,
  b.business_id,
  b.name AS business_name
FROM tbl_yelp_review r
JOIN top_users tu ON r.user_id = tu.user_id
JOIN tbl_yelp_business b ON r.business_id = b.business_id
group by 1,2,3
ORDER BY r.user_id;

-- QUERY 2
-- Step 1: Identify the top 10 users with the highest number of reviews.
-- Step 2: Return only the user_id and business_id pairs for those users.
-- This version is simpler and useful when only IDs are needed for further processing.

with top_users as (
select r.user_id, count(*) as total_review
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
group by 1
order by 2 desc
limit 10
)
select user_id,business_id
from tbl_yelp_review where user_id in (select user_id from top_users)
group by 1,2 
order by 1;


-- QUESTION 10:
-- Find top 10 businesses with the higest positive sentiment reviews
select r.business_id, b.name, count(*) as total_review
from tbl_yelp_review r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
where sentiments='Positive'
group by 1, 2
order by 3 desc
limit 10;
