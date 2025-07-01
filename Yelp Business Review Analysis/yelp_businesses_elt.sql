-- Description: This script extracts data from a JSON file containing Yelp business information, loads it into a Snowflake table, and transforms it into a structured format.
-- The script also includes a function to analyze sentiment from the reviews
create or replace table yelp_businesses (business_text variant)

copy into yelp_businesses
from 's3://yelp-ee41f29f/yelp_academic_dataset_business.json'
CREDENTIALS = (
    AWS_KEY_ID = 'AMAZON ACCESS KEY ID HERE' -- Replace with your actual AWS Access Key ID
    AWS_SECRET_KEY = 'Amazon Secret Access Key Here' -- Replace with your actual AWS Secret Access Key
)
FILE_FORMAT = (TYPE = JSON);

-- Converting json to table
create or replace table tbl_yelp_business as
select 
business_text:business_id::string as business_id,
business_text:city::string as city,
business_text:name::string as name,
business_text:state::string as state,
business_text:review_count::number as review_count,
business_text:stars::number as stars,
business_text:categories::string as categories
from yelp_businesses;



