/*
===============================================================================
Description:
This script performs data cleansing, standardization, and transformation
activities on Bronze Layer data before loading it into analytical structures.

Transformations Performed:
- Duplicate removal
- Missing value handling
- Data type corrections
- String standardization
- Country value standardization
- Data quality checks

Tables Processed:
- products
- suppliers
- inventory
- purchase_orders
- shipments
- warehouses

Source:
Bronze Schema Tables

Target:
Silver Schema Tables
===============================================================================
*/

drop table if exists silver.inventory;
create table silver.inventory(
inventory_id int,	
product_id	int,
warehouse_id int,	
stock_on_hand numeric(10,2),
reorder_point numeric(10,2),	
inventory_date date)

drop table if exists silver.products;
create table silver.products(
product_id int,
product_name varchar (50),
category varchar (50),	
unit_cost numeric(10,2) ,	
supplier_id int)

drop table if exists silver.purchase_orders_details;
create table silver.purchase_orders_details(
po_id int,	
supplier_id	int,
product_id	int,
order_date	date,
quantity_ordered int,	
expected_delivery date
)

drop table if exists silver.shipments;
create table silver.shipments(
shipment_id	int,
po_id int,
actual_delivery_date date,	
quantity_received numeric(10,2),
shipment_status varchar (50)
)

drop table if exists silver.suppliers;
create table silver.suppliers(
supplier_id	int,
supplier_name varchar (50),	
country	varchar (50),
supplier_rating	int,
lead_time_days int
)

drop table if exists silver.warehouses;
create table silver.warehouses(
warehouse_id int,	
warehouse_name	varchar (50),
city varchar (50),	
capacity int

)

create or replace procedure silver.load_silver()
language plpgsql
as $$
begin
-- loading silver.inventory

truncate table silver.inventory;
insert into silver.inventory(
inventory_id ,	
product_id	,
warehouse_id ,	
stock_on_hand ,
reorder_point ,	
inventory_date)

select 
inventory_id ,	
product_id	,
warehouse_id ,	
case when stock_on_hand is null then 0
when stock_on_hand < 0 then 0
else stock_on_hand
end as stock_on_hand,
reorder_point ,	
inventory_date
from bronze.inventory;

--loading silver.products
truncate table silver.products;
insert into silver.products(
product_id ,
product_name ,
category ,	
unit_cost ,	
supplier_id )

with deduplicated as(
select *,               
row_number() over(partition by product_id ,
product_name ,
category ,	
unit_cost ,	
supplier_id
order by product_id ) as rn from bronze.products)

select
product_id ,
trim(product_name) as product_name ,
case when upper(trim(category)) in ('ELECTRONICS', 'ELECTRONIC') then 'Electronics' 
else category
end as category,
coalesce(unit_cost,267.62) as unit_cost,
supplier_id
from deduplicated
where rn= 1;


-- loading silver.purchase_order_details

truncate table silver.purchase_orders_details;
insert into silver.purchase_orders_details(
po_id ,	
supplier_id	,
product_id	,
order_date	,
quantity_ordered,
expected_delivery
)
select 
po_id ,	
supplier_id	,
product_id	,
order_date	,
quantity_ordered,
coalesce(expected_delivery , order_date) + interval '30 days' as expected_delivery
from bronze.purchase_orders_details;

-- loading silver.suppliers


truncate table silver.suppliers;
insert into silver.suppliers(
supplier_id	,
supplier_name ,	
country,
supplier_rating,
lead_time_days
)

with deduplicated as (select *,
row_number() over(partition by supplier_id	,
supplier_name ,	
country,
supplier_rating,
lead_time_days
order by supplier_id) rn 
from bronze.suppliers)

select
supplier_id,
trim(supplier_name) ,	
country,
case when supplier_rating is null then 0
else supplier_rating
end as supplier_rating,
coalesce(lead_time_days, 30) as lead_time_days
from deduplicated
where rn = 1;

-- loading silver.shipments

TRUNCATE TABLE silver.shipments;
insert into silver.shipments(
shipment_id	,
po_id ,
actual_delivery_date ,	
quantity_received ,
shipment_status 
)

with deduplicated as 
(select *,
row_number()over(partition by shipment_id	,
po_id ,
actual_delivery_date ,	
quantity_received ,
shipment_status 
order by shipment_id) as rn
from bronze.shipments
)
select
shipment_id	,
po_id ,
actual_delivery_date ,	
case when quantity_received is null then 0
else quantity_received
end as quantity_received,
case when upper(trim(shipment_status )) in ('DELIVERED','DELIVERED') THEN 'Delivered'
else shipment_status
end as sghipment_status
from bronze.shipments;

-- loading silver.warehouse
truncate table silver.warehouses;
insert into silver.warehouses(
warehouse_id ,	
warehouse_name,
city,
capacity
)

select warehouse_id ,	
warehouse_name,
case when upper(trim(city)) in ('DELHI', 'DELHI') THEN 'Delhi'
else city
end as city,	
capacity
from bronze.warehouses;

end
$$

-- to execute stored procedure created
select routine_definition
from information_schema.routines
where routine_schema = 'silver'
and routine_name ='load_silver'
