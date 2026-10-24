-- 06_bronze_validation.sql
-- Purpose: Check every Bronze table loaded the same number of rows as its source CSV

-- Compare loaded row counts against the original CSV row counts
SELECT 'orders' AS table_name, COUNT(*) AS rows_loaded, 99441 AS expected FROM OLIST_DB.BRONZE.orders
UNION ALL SELECT 'order_items',          COUNT(*), 112650  FROM OLIST_DB.BRONZE.order_items
UNION ALL SELECT 'customers',            COUNT(*), 99441   FROM OLIST_DB.BRONZE.customers
UNION ALL SELECT 'products',             COUNT(*), 32951   FROM OLIST_DB.BRONZE.products
UNION ALL SELECT 'sellers',              COUNT(*), 3095    FROM OLIST_DB.BRONZE.sellers
UNION ALL SELECT 'payments',             COUNT(*), 103886  FROM OLIST_DB.BRONZE.payments
UNION ALL SELECT 'reviews',              COUNT(*), 99224   FROM OLIST_DB.BRONZE.reviews
UNION ALL SELECT 'geolocation',          COUNT(*), 1000163 FROM OLIST_DB.BRONZE.geolocation
UNION ALL SELECT 'category_translation', COUNT(*), 71      FROM OLIST_DB.BRONZE.category_translation;