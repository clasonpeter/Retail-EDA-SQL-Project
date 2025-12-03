CREATE DATABASE retail_analysis;
USE retail_analysis;

DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    product_description VARCHAR(255),
    quantity INT,
    invoice_date DATETIME,
    unit_price DECIMAL(10,2),
    customer_id INT,
    country VARCHAR(100)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(invoice_no, stock_code, product_description, quantity, @raw_invoice_date, unit_price, @raw_customer, country)
SET 
    invoice_date = STR_TO_DATE(@raw_invoice_date, '%m/%d/%Y %H:%i'),
    customer_id = NULLIF(@raw_customer, '');

/* ===========================================================
   PROJECT: ONLINE RETAIL SALES EXPLORATORY DATA ANALYSIS
   AUTHOR: Clason Peter
   DESCRIPTION:
   This SQL script explores customer behavior, product trends,
   sales performance, and return patterns for an online retail 
   business. The analysis supports business recommendations.
   =========================================================== */


/* ===========================================================
   SECTION 0 — CHECK DATA
   =========================================================== */

-- Quick row count and basic completeness check
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_description) AS distinct_products
FROM online_retail;

-- Sample a few rows to verify data quality
SELECT *
FROM online_retail
LIMIT 10;


/* ===========================================================
   SECTION 1 — CORE SALES METRICS
   =========================================================== */

-- Total Revenue (Quantity * Unit Price)
SELECT 
    SUM(quantity * unit_price) AS total_revenue
FROM online_retail;

-- Total Quantity Sold
SELECT 
    SUM(quantity) AS total_quantity_sold
FROM online_retail;


/* ===========================================================
   SECTION 2 — PRODUCT PERFORMANCE
   =========================================================== */

-- Top 10 Products by Revenue
SELECT 
    product_description,
    SUM(quantity * unit_price) AS revenue
FROM online_retail
GROUP BY product_description
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 Products by Quantity Sold
SELECT 
    product_description,
    SUM(quantity) AS total_units_sold
FROM online_retail
GROUP BY product_description
ORDER BY total_units_sold DESC
LIMIT 10;


/* ===========================================================
   SECTION 3 — CUSTOMER ANALYSIS
   =========================================================== */

-- Top 10 Most Valuable Customers (LTV-like metric)
SELECT 
    customer_id,
    SUM(quantity * unit_price) AS total_spend
FROM online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 10;

-- Total orders per customer
SELECT 
    customer_id,
    COUNT(DISTINCT invoice_no) AS number_of_orders
FROM online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY number_of_orders DESC;


/* ===========================================================
   SECTION 4 — TIME-BASED ANALYSIS
   =========================================================== */

-- Monthly Revenue Trend
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    SUM(quantity * unit_price) AS monthly_revenue
FROM online_retail
GROUP BY month
ORDER BY month;

-- Day of Week Sales Pattern
SELECT 
    DAYNAME(invoice_date) AS day_of_week,
    SUM(quantity * unit_price) AS revenue
FROM online_retail
GROUP BY day_of_week
ORDER BY revenue DESC;


/* ===========================================================
   SECTION 5 — RETURNS & REFUNDS ANALYSIS
   =========================================================== */

-- Summary of Returns (negative quantities)
SELECT 
    CASE WHEN quantity < 0 THEN 'Return' ELSE 'Purchase' END AS transaction_type,
    COUNT(*) AS total_transactions,
    SUM(quantity * unit_price) AS value
FROM online_retail
GROUP BY transaction_type;

-- Products with the highest return value
SELECT 
    product_description,
    SUM(quantity * unit_price) AS return_value
FROM online_retail
WHERE quantity < 0
GROUP BY product_description
ORDER BY return_value ASC
LIMIT 10;


/* ===========================================================
   SECTION 6 — GEOGRAPHIC ANALYSIS
   =========================================================== */

-- Revenue by Country
SELECT 
    country,
    SUM(quantity * unit_price) AS revenue
FROM online_retail
GROUP BY country
ORDER BY revenue DESC;


/* ===========================================================
   SECTION 7 — FINAL QUALITY CHECK
   =========================================================== */

-- Check for missing customer IDs
SELECT 
    COUNT(*) AS missing_customers
FROM online_retail
WHERE customer_id IS NULL OR customer_id = '';

-- Count return transactions
SELECT 
    COUNT(*) AS return_rows
FROM online_retail
WHERE quantity < 0;


