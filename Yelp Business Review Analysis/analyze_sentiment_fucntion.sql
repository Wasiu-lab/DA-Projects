--UDF
-- This function analyzes the sentiment of a given text using TextBlob.
-- It returns 'Positive', 'Neutral', or 'Negative' based on the sentiment polarity.
-- The function is designed to be used in Snowflake SQL to analyze Yelp reviews. 
select review, analyze_sentiment from yelp_reviews
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
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