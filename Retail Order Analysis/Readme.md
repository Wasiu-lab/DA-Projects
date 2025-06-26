# Retail Order Analysis Project

## Overview
This project analyzes retail order data to extract meaningful business insights using Python and SQL. The analysis focuses on sales performance, product profitability, regional trends, and growth patterns across different time periods.

## Dataset
The project uses the **Retail Orders** dataset from Kaggle, which contains comprehensive information about retail transactions, including:
- Order details (ID, date, shipping mode)
- Customer segmentation data
- Geographic information (country, state, city, region)
- Product categorization
- Financial metrics (cost price, list price, quantity, discount)

**Dataset Source**: [Kaggle - Retail Orders Dataset](https://www.kaggle.com/datasets/ankitbansal06/retail-orders)

## Project Structure
```
Retail Order Analysis/
├── README.md
├── order data Analysis.ipynb    # Data processing and MySQL integration
├── SQL Analysis.sql             # SQL queries for business insights
└── orders.csv                  # Raw dataset (downloaded from Kaggle)
```

## Technologies Used
- **Python**: Data processing and analysis
  - pandas: Data manipulation and cleaning
  - sqlalchemy: Database connectivity
  - Kaggle API: Dataset download
  - python-dotenv: Environment variable management
- **MySQL**: Data storage and advanced analytics
- **Jupyter Notebook**: Interactive development environment

## Features

### Data Processing Pipeline
1. **Data Acquisition**: Automated download from Kaggle using API
2. **Data Cleaning**: 
   - Handling null values (replacing 'Not Available', 'unknown' with NaN)
   - Column standardization (lowercase, underscore separation)
   - Data type conversion (date formatting)
3. **Feature Engineering**:
   - Calculated discount amounts
   - Derived sale prices
   - Computed profit margins
4. **Database Integration**: Seamless loading into MySQL database

### Business Analytics

#### Sales Performance Analysis
- **Top Revenue Products**: Identification of highest revenue-generating products
- **Regional Performance**: Top 5 selling products by region
- **Category Analysis**: Best performing months for each product category

#### Growth Analytics
- **Year-over-Year Comparison**: Monthly sales comparison between 2022 and 2023
- **Profitability Growth**: Sub-category growth analysis with percentage calculations
- **Trend Analysis**: Time-based performance patterns

#### Product Insights
- **Top Performers**: Best-selling products and categories by various metrics
- **Loss Analysis**: Identification of loss-making products and categories
- **Profitability Ranking**: Products ranked by profit margins

## Key SQL Queries

### 1. Top Revenue Products
```sql
SELECT product_id, SUM(sale_price) as sales 
FROM orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;
```

### 2. Regional Top Performers
```sql
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) as sales 
    FROM orders
    GROUP BY region, product_id
)
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) as rn
    FROM cte
) A 
WHERE rn <= 5;
```

### 3. Year-over-Year Growth
```sql
WITH cte AS (
    SELECT YEAR(order_date) as order_year, MONTH(order_date) as order_month, 
           SUM(sale_price) as sales
    FROM orders 
    GROUP BY order_year, order_month
)
SELECT order_month,
    SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) as sales_2022, 
    SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) as sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;
```

## Setup Instructions

### Prerequisites
- Python 3.7+
- MySQL Server
- Kaggle API credentials

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd retail-order-analysis
```

2. **Install required packages**
```bash
pip install pandas sqlalchemy pymysql python-dotenv kaggle
```

3. **Configure Kaggle API**
   - Download your Kaggle API key from your account settings
   - Place `kaggle.json` in `~/.kaggle/` directory
   - Set permissions: `chmod 600 ~/.kaggle/kaggle.json`

4. **Setup MySQL Database**
   - Create a MySQL database named 'world'
   - Create a `.env` file with your MySQL credentials:
```env
MYSQL_USER=your_username
MYSQL_PASSWORD=your_password
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=world
```

5. **Run the Analysis**
   - Execute the Jupyter notebook: `order data Analysis.ipynb`
   - Run SQL queries from: `SQL Analysis.sql`

## Database Schema

The `orders` table contains the following columns:
- `order_id`: Unique identifier for each order
- `order_date`: Date when the order was placed
- `ship_mode`: Shipping method used
- `segment`: Customer segment (Consumer, Corporate, etc.)
- `country`, `city`, `state`, `postal_code`: Geographic information
- `region`: Geographic region
- `category`, `sub_category`: Product classification
- `product_id`: Unique product identifier
- `quantity`: Number of items ordered
- `discount`: Discount amount applied
- `sale_price`: Final selling price
- `profit`: Profit margin per transaction

## Key Insights

The analysis reveals several critical business insights:

1. **Product Performance**: Clear identification of top revenue-generating products across different regions
2. **Seasonal Trends**: Monthly performance patterns help optimize inventory and marketing strategies
3. **Growth Opportunities**: Year-over-year analysis highlights areas of growth and decline
4. **Loss Prevention**: Identification of loss-making products enables strategic decision-making

## Future Enhancements

- **Interactive Dashboards**: Implementation of visualization tools (Tableau, Power BI)
- **Predictive Analytics**: Machine learning models for sales forecasting
- **Customer Segmentation**: Advanced customer behavior analysis
- **Real-time Analytics**: Integration with live data streams
