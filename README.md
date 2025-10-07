# 💳 Credit Card Spending Analysis using SQL

A complete **SQL Data Analysis Project** where I cleaned, transformed, and analyzed credit card transaction data to extract key business insights such as city-level spending, gender-based patterns, and month-over-month trends.

---

## 📊 Project Overview

This project focuses on understanding **credit card spending behavior** using SQL queries.  
It covers:
- Data Cleaning & Transformation
- Exploratory Data Analysis (EDA)
- Analytical SQL queries for insights

---

## 🧰 Tools & Technologies

- **MySQL** for database management and query execution  
- **Excel / CSV** for raw dataset  
- **GitHub** for project version control  

---

## 🧹 Data Cleaning Steps

1. Verified and corrected column data types  
2. Formatted transaction dates  
3. Removed unnecessary columns  
4. Renamed table and columns for consistency  

```sql
ALTER TABLE credit_card_transactions
CHANGE COLUMN new_date transaction_date DATE;
