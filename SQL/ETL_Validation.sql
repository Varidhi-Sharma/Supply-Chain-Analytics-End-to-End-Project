/*
===============================================================================
Description:
This script contains validation checks used to verify the accuracy,
completeness, and integrity of data after ETL processing.

Validation Activities:
- Row Count Validation
- Null Foreign Key Validation
- Duplicate Key Validation
- Measure Reconciliation Validation

Purpose:
Ensure data consistency across Bronze, Silver, and Gold layers before
consumption in Power BI dashboards.

Expected Result:
All validation checks should return successful results with no data
quality issues detected.
===============================================================================
*/

-- ETL Validation Checklist 

-- 1.Row Count validtaion
--dim_suppliers
select count(*)  as silver_count
from silver.suppliers;

select count(*)  as gold_count
from gold.dim_suppliers;

--dim_products
select count(*)  as silver_count
from silver.products;

select count(*)  as gold_count
from gold.dim_products;

--dim_warehouses
select count(*)  as silver_count
from silver.warehouses;

select count(*)  as gold_count
from gold.dim_warehouses;

--dim_date
select count(*) from gold.dim_date

-- fact_procurement
select count(*)  as silver_count
from silver.purchase_orders_details;

select count(*)  as gold_count
from gold.fact_procurement;

--fact_inventory
select count(*)  as silver_count
from silver.inventory;

select count(*)  as gold_count
from gold.fact_inventory;

-- 2. Null foreign key validation
--fact_procurement
select count(*) from gold.fact_procurement
where supplier_key is null
or product_key is null
or order_date_key is null
or expected_delivery_date_key is null
or actual_delivery_date_key is null

-- fact_inventory
select count(*) from gold.fact_inventory
where warehouse_key is null
or product_key is null
or inventory_date_key is null

-- 3. Duplicate Business key Validation
-- dim_supplier
select supplier_id, count(*)
from gold.dim_suppliers
group by supplier_id
having count(*) > 1

-- dim_products
select product_id, count(*)
from gold.dim_products
group by product_id
having count(*) > 1

--dim_warehouses
select warehouse_id, count(*)
from gold.dim_warehouses
group by warehouse_id
having count(*) > 1

--4. Measure Validation
--ordered quantity
select sum(quantity_ordered)
from silver.purchase_orders_details
select sum(quantity_ordered)
from gold.fact_procurement

-- quantity received
select sum(quantity_received)
from silver.shipments
select sum(quantity_received)
from gold.fact_procurement

-- stock on hand
select sum(stock_on_hand)
from silver.inventory
select sum(stock_on_hand)
from gold.fact_inventory
