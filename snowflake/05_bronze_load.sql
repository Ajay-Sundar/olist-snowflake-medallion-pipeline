-- 05_bronze_load.sql
-- Purpose: Load raw CSVs from S3 into the Bronze tables
-- Each table reads from its own S3 folder and records the source file and load time
-- Snowflake skips files it has already loaded, so re-running won't create duplicates

USE WAREHOUSE SNOWFLAKE_LEARNING_WH;
USE SCHEMA OLIST_DB.BRONZE;

COPY INTO orders FROM (
  SELECT $1, $2, $3, $4, $5, $6, $7, $8, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/orders/
);

COPY INTO order_items FROM (
  SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/order_items/
);

COPY INTO customers FROM (
  SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/customers/
);

COPY INTO products FROM (
  SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/products/
);

COPY INTO sellers FROM (
  SELECT $1, $2, $3, $4, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/sellers/
);

COPY INTO payments FROM (
  SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/payments/
);

COPY INTO reviews FROM (
  SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/reviews/
);

COPY INTO geolocation FROM (
  SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/geolocation/
);

COPY INTO category_translation FROM (
  SELECT $1, $2, METADATA$FILENAME, CURRENT_TIMESTAMP()
  FROM @olist_s3_stage/category_translation/
);