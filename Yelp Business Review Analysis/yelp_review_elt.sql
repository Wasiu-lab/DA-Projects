-- The query below creates a table to store the business data from Yelp
-- It was written in snowflake SQL
create or replace table yelp_reviews (review_text variant)

copy into yelp_reviews
from 's3://yelp-ee41f29f'
CREDENTIALS = (
    AWS_KEY_ID = 'Amazon S3 Access Key ID'
    AWS_SECRET_KEY = 'Amazon S3 Secret Access Key'
)
FILE_FORMAT = (TYPE = JSON);

-- creating the sentimental function to be able to run sentimental analysis
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;

select * from yelp_reviews limit 2;
-- Converting JSON to table then create a new table to load it in 
create or replace table tbl_yelp_review as 
select 
review_text:business_id::string as business_id,
review_text:date::date as review_date,
review_text:user_id::string as user_id,
review_text:stars::number as review_stars,
review_text:text::string as review_text,
analyze_sentiment(review_text) as sentiments
from yelp_reviews;

  
select * from tbl_yelp_review limit 10;
select * from tbl_yelp_business limit 10;




