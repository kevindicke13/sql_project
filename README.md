ShopSmart: Sales Data Analysis & Transformation
This repository contains a data analytics project focused on retail sales performance. Using SQL and dbt, I transformed raw transactional data into actionable business insights regarding customer behavior, product performance, and promotional impact.

📊 Project Overview
The goal of this project is to build a robust data pipeline that converts raw CSV exports into a structured analytical layer. This allows for quick reporting on key sales metrics and helps identify which promotions are driving the most value.

Tech Stack
* SQL: For complex data joins and business logic.
* dbt (data build tool): To manage data transformations and ensure data quality through testing.
* Data Modeling: Implementation of a staging-to-marts workflow.

🏗️ Data Structure
* The project utilizes the following core data entities:
* Customers: Demographic and profile data.
* Orders & Order Items: Transactional history and line-item details.
* Products: Product catalog and categorization.
* Promotions: Data on marketing campaigns applied to sales.
Transformation Layers
Staging: Mapping raw ext_* files to standardized table formats.

Marts: Creating aggregate tables for "Sales per Category," "Promotion Success Rate," and "Customer Lifetime Value."

📂 Repository Contents
* ext_*.csv: The raw source datasets for the project.
* sales_project.sql: SQL scripts used for data exploration and final views.
* shop_smart.md: Documentation or project notes regarding the ShopSmart business logic.

📈 Key Analysis Areas
* Promotion Impact: Analyzing the lift in sales volume during specific promotional periods.
* Product Performance: Identifying "Hero Products" versus low-velocity items.
* Customer Retention: Tracking repeat purchase rates and average order value (AOV).
