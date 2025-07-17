# Yelp Business Review Analysis

A comprehensive data engineering and analytics project that processes Yelp's business review dataset using cloud infrastructure (AWS S3, Snowflake) and performs sentiment analysis to extract business insights.

## 🎯 Project Overview

This project analyzes Yelp's publicly available dataset to uncover business insights through:
- **Sentiment Analysis**: Classifying reviews as positive, negative, or neutral using TextBlob
- **Rating Pattern Analysis**: Understanding distribution of star ratings across businesses
- **Business Performance Metrics**: Identifying top-performing businesses and categories
- **Temporal Trends**: Analyzing review patterns over time
- **Cloud-Native Architecture**: Leveraging AWS S3 for storage and Snowflake for analytics

## 📁 Project Structure

```
Yelp Business Review Analysis/

├── Yelp_Business_Review_Analysis.ipynb      # Main analysis notebook
├── Yelp-files-split.py                     # Script to split large JSON files
├── main.tf                                 # Terraform infrastructure code
├── yelp_businesses_elt.sql                 # Business data ELT pipeline
├── yelp_review_elt.sql                     # Review data ELT pipeline
├── yelp_data_analysis.sql                  # Business analysis queries
├── analyze_sentiment_function.sql          # Sentiment analysis UDF
├── .gitignore                              # Git ignore rules
└── README.md                               # Project documentation
```

## 🚀 Key Features

### Data Processing Pipeline
- **File Splitting**: Handles large JSON files (5GB+) by splitting into manageable chunks
- **Cloud Storage**: Automated upload to AWS S3 using Terraform
- **Data Loading**: Efficient ELT process into Snowflake data warehouse
- **Schema Transformation**: JSON to structured table conversion

### Analytics Capabilities
- **Sentiment Analysis**: Custom Python UDF using TextBlob for review sentiment classification
- **Business Intelligence**: 10+ pre-built analytical queries answering key business questions
- **Performance Metrics**: Review counts, rating distributions, and trending analysis
- **Category Analysis**: Business categorization and performance by industry

### Infrastructure as Code
- **Terraform**: Automated AWS S3 bucket creation and file uploads
- **Snowflake Integration**: Seamless data pipeline from S3 to Snowflake
- **Scalable Architecture**: Designed to handle millions of reviews

## 📊 Sample Analysis Questions

The project answers critical business questions such as:

1. **Category Performance**: Number of businesses in each category
2. **User Engagement**: Top reviewers by category (e.g., restaurants)
3. **Popular Categories**: Most reviewed business types
4. **Recent Activity**: Latest reviews for each business
5. **Seasonal Trends**: Monthly review patterns
6. **Quality Metrics**: Percentage of 5-star reviews per business
7. **Geographic Analysis**: Top businesses by city
8. **Review Thresholds**: Average ratings for high-volume businesses (100+ reviews)
9. **User Behavior**: Most active reviewers and their preferences
10. **Sentiment Insights**: Businesses with highest positive sentiment

## 🛠️ Technical Stack

### Cloud Services
- **AWS S3**: Data lake storage for raw JSON files
- **Snowflake**: Data warehouse for analytics and processing
- **Terraform**: Infrastructure automation and management

### Programming Languages & Tools
- **Python**: Data processing, analysis, and visualization
- **SQL**: Data transformation and business intelligence queries
- **Jupyter Notebook**: Interactive analysis environment

### Key Libraries
- **Data Processing**: pandas, numpy
- **Sentiment Analysis**: TextBlob, NLTK
- **Visualization**: matplotlib, seaborn
- **Cloud Integration**: snowflake-connector-python, boto3
- **File Processing**: json (built-in)

## 🔧 Setup Instructions

### Prerequisites
- Python 3.8+
- AWS Account with S3 access
- Snowflake Account with database access
- Terraform installed
- Git

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Wasiu-lab/DA-Projects.git
   cd "DA-Projects/Yelp Business Review Analysis"
   ```

2. **Create Virtual Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Prepare Large Dataset Files**
   ```bash
   # Split large JSON files if needed
   python Yelp-files-split.py
   ```

5. **Deploy Infrastructure**
   ```bash
   # Initialize and apply Terraform
   terraform init
   terraform plan
   terraform apply
   ```

6. **Configure Database Connection**
   - Update SQL files with your AWS credentials
   - Configure Snowflake connection parameters
   - Run ELT scripts in order:
     ```sql
     -- Execute in Snowflake
     @yelp_businesses_elt.sql
     @yelp_review_elt.sql
     @analyze_sentiment_function.sql
     ```

## 📈 Usage Examples

### Basic Sentiment Analysis
```python
import snowflake.connector
import pandas as pd

# Connect to Snowflake
conn = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account',
    warehouse='your_warehouse',
    database='yelp_db'
)

# Analyze sentiment distribution
query = """
SELECT sentiments, COUNT(*) as count
FROM tbl_yelp_review
GROUP BY sentiments
ORDER BY count DESC
"""

df = pd.read_sql(query, conn)
print(df)
```

### Business Performance Analysis
```sql
-- Top 10 businesses with highest positive sentiment
SELECT r.business_id, b.name, COUNT(*) as positive_reviews
FROM tbl_yelp_review r
JOIN tbl_yelp_business b ON r.business_id = b.business_id
WHERE sentiments='Positive'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;
```

## 📊 Sample Results

### Sentiment Distribution
- **Positive**: 68% of reviews
- **Negative**: 22% of reviews  
- **Neutral**: 10% of reviews

### Top Business Categories
1. Restaurants: 45,000+ businesses
2. Food Services: 23,000+ businesses
3. Shopping: 18,000+ businesses

### Review Patterns
- **Peak Month**: March (highest review volume)
- **Average Rating**: 3.7/5 stars
- **High-Volume Businesses**: 15% have 100+ reviews

## 🔍 Advanced Features

### Custom Sentiment Analysis Function
```sql
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
```

### Automated File Processing
The `Yelp-files-split.py` script handles large datasets:
- Splits 5GB+ JSON files into 20 manageable chunks
- Preserves data integrity with UTF-8 encoding
- Optimizes for parallel processing

## 📋 Data Schema

### Business Table (`tbl_yelp_business`)
| Column | Type | Description |
|--------|------|-------------|
| business_id | STRING | Unique business identifier |
| name | STRING | Business name |
| city | STRING | Business location |
| state | STRING | Business state |
| stars | NUMBER | Average rating |
| review_count | NUMBER | Total reviews |
| categories | STRING | Business categories |

### Review Table (`tbl_yelp_review`)
| Column | Type | Description |
|--------|------|-------------|
| business_id | STRING | Business identifier |
| user_id | STRING | Reviewer identifier |
| review_date | DATE | Review date |
| review_stars | NUMBER | Review rating (1-5) |
| review_text | STRING | Review content |
| sentiments | STRING | Sentiment classification |

## 🚧 Troubleshooting

### Common Issues

**AWS S3 Connection Errors**
- Verify AWS credentials in SQL files
- Check S3 bucket permissions
- Ensure bucket region matches configuration

**Snowflake Connection Issues**
- Validate account details and warehouse availability
- Check network policies and firewall settings
- Verify database and schema permissions

**Large File Processing**
- Use file splitting script for datasets >1GB
- Monitor Snowflake compute resources
- Consider data sampling for initial testing

**Memory Issues**
- Process data in smaller batches
- Optimize SQL queries for performance
- Use appropriate Snowflake warehouse size

## 🔮 Future Enhancements

- **Advanced NLP**: Integration with BERT or GPT models
- **Real-time Processing**: Stream processing capabilities
- **Geographic Analysis**: Location-based insights with mapping
- **Automated Reporting**: Scheduled dashboard updates
- **ML Models**: Predictive analytics for business performance
- **Data Pipeline Automation**: Apache Airflow integration
