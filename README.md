# Supply-Chain-Analytics-End-to-End-Project
## Project Overview

This project demonstrates an end-to-end Supply Chain Analytics solution using:

- SQL Data Warehouse
- ETL Pipeline
- Star Schema Data Modeling
- Power BI Dashboarding
- DAX Measures

The objective is to transform raw operational supply chain data into actionable business insights for procurement, supplier performance, and inventory management.

| Tool       | Purpose                                |
| ---------- | -------------------------------------- |
| PostgreSQL | Data warehouse and ETL                 |
| SQL        | Data cleaning and transformations      |
| Power BI   | Reporting and visualization            |
| DAX        | KPI calculations                       |

## Project Architecture
The project follows a modern Medallion Architecture (Bronze → Silver → Gold) approach.

### 1. Bronze Layer
Raw source files loaded into SQL without transformations.

### 2. Silver Layer
SQL-based cleaning, validation, and standardization.

### 3. Gold Layer
Star schema consisting of fact and dimension tables optimized for reporting.

### 4. Power BI
Interactive dashboards for Procurement, Supplier Performance, and Inventory Health.

## Data Warehouse Design
### - Bronze Layer
Raw data loaded without transformations.

#### Tables:
- products
- suppliers
- inventory
- purchase_orders_details
- shipments
- warehouses

### - Silver Layer
Data cleansing and standardization performed using SQL.

#### Activities:
- Remove duplicates
- Handle null values
- Trim unwanted spaces
- Standardize country values
- Validate data types

### - Gold Layer
Business-ready star schema.

#### = Fact Tables:
- Fact Procurement
- Fact Inventory

#### - Dimension Tables:
- Dim Date
- Dim Products
- Dim Suppliers
- Dim Warehouses

### Dataset
This project uses a synthetic supply chain dataset created for portfolio and educational purposes. The data simulates purchase orders details, supplier, inventory, shipment, and warehouse operations and includes realistic data quality issues to support ETL and analytics workflows.

### Key Performance Indicators
#### 1.Procurement
- Total Orders
- Fill Rate %
- Total Ordered Quantity
- Total Received Quantity

#### 2.Supplier Performance
- Average Supplier Rating
- On-Time Delivery %
- Delivery Variance
- Inventory
- Total Stock
- Low Stock Products
- Average Stock per Warehouse
  
### Dashboard Pages
#### 1.Executive Overview
Provides a high-level summary of supply chain performance.

Features:
- Total Orders
- Fill Rate %
- Order Trends
- Top Products

#### 2.Supplier Performance Analysis
Provides supplier-level insights.

Features:
- Fill Rate by Supplier
- Supplier Ratings
- On-Time Deliveries vs Late Deliveries
- Supplier Country Distribution

#### 3.Inventory Health & Warehouse Analysis
Provides inventory monitoring capabilities.

Features:
- Inventory by Category
- Stock by Warehouse
- Low Stock Products
- Reorder Point Analysis

### Business Insights
#### Examples:
- Fill Rate maintained at approximately 97%.
- Several products remain below reorder point.
- Top suppliers consistently achieve high delivery performance.
- Electronics category contributes the highest inventory volume.

### Skills Demonstrated
#### SQL
- ETL Development
- Data Cleaning
- Data Transformation
- Star Schema Modeling
  
#### Power BI
- Data Modeling
- DAX Measures
- Dashboard Design
- KPI Development
  
#### Analytics
- Procurement Analytics
- Supplier Analytics
- Inventory Analytics
