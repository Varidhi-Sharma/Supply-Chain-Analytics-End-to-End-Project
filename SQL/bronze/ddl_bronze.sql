/*
===============================================================================
Description:
This script creates the Bronze Layer of the data warehouse.

The Bronze Layer serves as the raw ingestion layer where source files are
loaded into SQL tables without applying any transformations or business rules.

Tables Included:
- products
- suppliers
- inventory
- purchase_orders_details
- shipments
- warehouses

Key Characteristics:
- Raw data preserved in original form
- No cleaning or validation performed
- Acts as the source for downstream ETL processes

Source:
CSV Files

Target:
Bronze Schema Tables
===============================================================================
*/

drop table if exists bronze.inventory;
create table bronze.inventory(
inventory_id int,	
product_id	int,
warehouse_id int,	
stock_on_hand numeric(10,2),
reorder_point numeric(10,2),	
inventory_date date)

drop table if exists bronze.products;
create table bronze.products(
product_id int,
product_name varchar (50),
category varchar (50),	
unit_cost numeric(10,2) ,	
supplier_id int

)
drop table if exists bronze.purchase_orders_details;
create table bronze.purchase_orders_details(
po_id int,	
supplier_id	int,
product_id	int,
order_date	date,
quantity_ordered int,	
expected_delivery date

)
drop table if exists bronze.shipments;
create table bronze.shipments(
shipment_id	int,
po_id int,
actual_delivery_date date,	
quantity_received numeric(10,2),
shipment_status varchar (50)

)
drop table if exists bronze.suppliers;
create table bronze.suppliers(
supplier_id	int,
supplier_name varchar (50),	
country	varchar (50),
supplier_rating	int,
lead_time_days int

)
drop table if exists  bronze.warehouses;
create table bronze.warehouses(
warehouse_id int,	
warehouse_name	varchar (50),
city varchar (50),	
capacity int

)

