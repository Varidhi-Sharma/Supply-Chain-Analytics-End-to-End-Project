/*
===============================================================================
Description:
This script creates the business-ready analytical layer using a Star Schema data model optimized for reporting and dashboarding.

Dimension Tables:
- dim_date
- dim_products
- dim_suppliers
- dim_warehouses

Fact Tables:
- fact_procurement
- fact_inventory

Business Objectives:
- Procurement Analytics
- Supplier Performance Analysis
- Inventory Health Monitoring
- Warehouse Analysis

Source:
Silver Schema Tables

Target:
Gold Schema Tables
===============================================================================
*/

-- creating dimension tables

-- gold.dim_suppliers
drop table if exists gold.dim_suppliers;
create table gold.dim_suppliers(
supplier_key serial primary key,  
supplier_id	int,
supplier_name varchar (50),	
country	varchar (50),
supplier_rating	int,
lead_time_days int
)

truncate table gold.dim_suppliers;
insert into gold.dim_suppliers(
supplier_id	,
supplier_name,	
country,
supplier_rating,
lead_time_days 
)
select 
supplier_id	,
supplier_name,	
country,
supplier_rating	,
lead_time_days 
from silver.suppliers

--gold.dim_products
drop table if exists gold.dim_products;
create table gold.dim_products(
product_key serial primary key, -- surrogate key
product_id int,
product_name varchar (50),
category varchar (50),	
unit_cost numeric(10,2) ,	
supplier_id int)

truncate table gold.dim_products;
insert into gold.dim_products( 
product_id ,
product_name ,
category ,	
unit_cost  ,	
supplier_id)

select 
product_id ,
product_name ,
category ,	
unit_cost  ,	
supplier_id 
from silver.products


-- gold.dim_warehouses
drop table if exists gold.dim_warehouses;
create table gold.dim_warehouses(
warehouse_key serial primary key,
warehouse_id int,	
warehouse_name	varchar (50),
city varchar (50),	
capacity int
)

truncate table gold.dim_warehouses;
insert into  gold.dim_warehouses(
warehouse_id ,	
warehouse_name,
city ,	
capacity 
)
select  
 warehouse_id ,	
warehouse_name,
city ,	
capacity 
from silver.warehouses

-- gold.dim_date
drop table if exists gold.dim_date;
create table gold.dim_date(
date_key int primary key,
full_date date not null,
day_number int,
month_number int,
month_name varchar(50),
quarter_number int,
year_number int,
week_number int,
day_name varchar (50)
)

truncate table gold.dim_date;
insert into gold.dim_date(
date_key ,
full_date ,
day_number ,
month_number ,
month_name ,
quarter_number ,
year_number ,
week_number ,
day_name
)

select 
to_char (d,'YYYYMMDD') :: int,
d,
extract(day from d):: int,
extract(month from d):: int,
trim(to_char(d, 'month')),
extract(quarter from d):: int,
extract(Year from d):: int,
extract(week from d):: int,
trim(to_char (d,'day'))
from generate_series(
'2024-01-01'::date,
'2026-12-31':: date,
'1 day')
as d;

-- creating fact tables

--gold.fact_procurement
drop table if exists gold.fact_procurement;
create table gold.fact_procurement(
purchase_order_id int ,
shipment_id	int,
supplier_key int,
 product_key int,
order_date_key int,
expected_delivery_date_key int,
actual_delivery_date_key int, 
quantity_ordered int,
quantity_received numeric(10,2),
delivery_delay_days int,
shipment_status varchar (50),
foreign key (supplier_key)
references gold.dim_suppliers(supplier_key),
foreign key (product_key)
references gold.dim_products(product_key),
foreign key (order_date_key)
references gold.dim_date(date_key),
foreign key (expected_delivery_date_key)
references gold.dim_date(date_key),
foreign key (actual_delivery_date_key)
references gold.dim_date(date_key)
)

truncate table gold.fact_procurement;
insert into gold.fact_procurement(
purchase_order_id  ,
shipment_id	,
supplier_key ,
 product_key ,
order_date_key ,
expected_delivery_date_key ,
actual_delivery_date_key ,
quantity_ordered ,
quantity_received ,
delivery_delay_days ,
shipment_status 
)

select 
p.po_id as purchase_order_id  ,
s.shipment_id	,
ds.supplier_key ,
dp. product_key ,
to_char(p.order_date, 'YYYYMMDD'):: int,
to_char(p.expected_delivery, 'YYYYMMDD'):: int as expected_delivery_date_key ,
to_char(s.actual_delivery_date, 'YYYYMMDD'):: int,
p.quantity_ordered ,
s.quantity_received ,
case when s.actual_delivery_date is not null
then (s.actual_delivery_date - p.expected_delivery)
else null
end as delivery_delay_days, 
s.shipment_status 
from silver.purchase_orders_details as p
left join silver.shipments as s
on p.po_id = s.po_id
left join gold.dim_suppliers as ds
on p.supplier_id = ds.supplier_id
left join  gold.dim_products as dp
on p.product_id = dp.product_id


-- gold.fact_inventory
drop table if exists gold.fact_inventory;
create table gold.fact_inventory(
inventory_key serial primary key,
inventory_id int, 
product_key int,
warehouse_key int,
inventory_date_key int,
stock_on_hand numeric(10,2),
reorder_point numeric(10,2),
foreign key (product_key)
references gold.dim_products(product_key),
foreign key (warehouse_key)
references gold.dim_warehouses(warehouse_key),
foreign key (inventory_date_key)
references gold.dim_date(date_key)
)

truncate table gold.fact_inventory;
insert into gold.fact_inventory(
inventory_id , 
product_key,
warehouse_key ,
inventory_date_key ,
stock_on_hand ,
reorder_point 
)

select 
i.inventory_id , 
p.product_key,
w.warehouse_key ,
to_char(i.inventory_date,'YYYYMMDD' ) :: int,
i.stock_on_hand ,
i.reorder_point 
from silver.inventory as i
left join gold.dim_products as p
on i.product_id = p.product_id
left join gold.dim_warehouses as w
on i.warehouse_id = w.warehouse_id


-- analytical SQL views
  
-- 1. supplier performance analysis
-- business questions
-- Which suppliers deliver late and which suppliers deliver early?
-- Which supplier receives most orders?

create or replace view gold.vw_suppliers_performance as
select s.supplier_name,
s.country,
s.supplier_rating,
count(fp.purchase_order_id) as total_orders,
sum(fp.quantity_ordered) as total_ordered_quantity,
sum(fp.quantity_received) as total_received_quantity,
round(avg(fp.delivery_delay_days),2) as avg_delivery_delay_days
from gold.fact_procurement as fp
join gold.dim_suppliers as s
on s.supplier_key = fp.supplier_key
group by supplier_name,
country,
supplier_rating

-- 2. Procurement Summary
--  business questions
-- Procurement trend by month
-- Ordered vs Received quantity
-- Supply Fulfillment

create or replace view gold.vw_procurement_summary as
select d.year_number,
d.month_name,
sum(p.quantity_ordered) as total_ordered_quantity,
sum(p.quantity_received) as total_received_quantity,
round(sum(p.quantity_received) * 100/nullif(sum(p.quantity_ordered),0),2) as fill_rate
from gold.fact_procurement as p
join gold.dim_date as d
on p.order_date_key = d.date_key
group by 
year_number,
month_name

-- 3. Inventory Health
-- Which products are below reorder point?
-- Which warehouses have low stock?

create or replace view gold.vw_inventory_health as
select
p.product_name,
p.category,
w.warehouse_name,
w.city,
i.stock_on_hand,
i.reorder_point,
case when i.stock_on_hand < i.reorder_point
then 'Reorder Required'
else 'Stock Sufficient'
end as inventory_status
from gold.fact_inventory as i
join gold.dim_products as p
on i.product_key = p.product_key
join gold.dim_warehouses as w
on i.warehouse_key = w.warehouse_key

-- 4. Delivery Performance
-- Business Question
-- Early vs On-time vs late deliveries
-- Delivery trends

create or replace view gold.vw_delivery_performance as 
select
fp.purchase_order_id,
fp.shipment_id,
s.supplier_name,
fp.delivery_delay_days,
case when fp.delivery_delay_days < 0 
then 'Early'
when fp.delivery_delay_days = 0 
then 'On Time'
else 'Late'
end as delivery_status,
fp.shipment_status
from gold.fact_procurement as fp
join gold.dim_suppliers as s
on fp.supplier_key = s.supplier_key


