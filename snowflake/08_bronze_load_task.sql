-- 08_bronze_load_task.sql
-- Purpose: Load new files from S3 into Bronze automatically every day at 6:00 am (Sydney)
-- COPY INTO skips files already loaded, so daily runs never create duplicates

-- Note: Runs as ACCOUNTADMIN for simplicity. In production, use a dedicated
-- least-privilege role (e.g. LOADER_ROLE) with write access to Bronze only.

USE ROLE ACCOUNTADMIN;
USE SCHEMA OLIST_DB.BRONZE;

CREATE OR REPLACE TASK bronze_daily_load
  WAREHOUSE = SNOWFLAKE_LEARNING_WH
  SCHEDULE = 'USING CRON 0 6 * * * Australia/Sydney'
AS
EXECUTE IMMEDIATE
$$
BEGIN
  COPY INTO orders FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, $8, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/orders/);

  COPY INTO order_items FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/order_items/);

  COPY INTO customers FROM (
    SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/customers/);

  COPY INTO products FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/products/);

  COPY INTO sellers FROM (
    SELECT $1, $2, $3, $4, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/sellers/);

  COPY INTO payments FROM (
    SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/payments/);

  COPY INTO reviews FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/reviews/);

  COPY INTO geolocation FROM (
    SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/geolocation/);

  COPY INTO category_translation FROM (
    SELECT $1, $2, METADATA$FILENAME, CURRENT_TIMESTAMP()
    FROM @olist_s3_stage/category_translation/);
END;
$$;

-- Tasks are created paused; this switches the schedule on
ALTER TASK bronze_daily_load RESUME;