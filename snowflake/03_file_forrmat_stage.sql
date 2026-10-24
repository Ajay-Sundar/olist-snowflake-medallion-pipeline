-- 03_file_format_stage.sql
-- Purpose: Define how to read the CSVs and where to find them in S3

USE SCHEMA OLIST_DB.BRONZE;

-- Rules for reading the Olist CSV files
CREATE OR REPLACE FILE FORMAT olist_csv_format
  TYPE = CSV
  FIELD_DELIMITER = ','               -- Columns separated by commas
  SKIP_HEADER = 1                     -- First row is column names
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'  -- Text may be wrapped in quotes
  EMPTY_FIELD_AS_NULL = TRUE          -- Treat empty values as NULL
  NULL_IF = ('', 'NULL');

-- Shortcut to the S3 bucket, using a read-only AWS user's access keys
-- (Role-based storage integration was blocked on the AWS Free plan)
-- Never commit real keys: replace the placeholders only when running in Snowflake
CREATE OR REPLACE STAGE olist_s3_stage
  URL = 's3://ajay-olist-ecommerce-raw/'
  CREDENTIALS = (
    AWS_KEY_ID = '<YOUR_ACCESS_KEY_ID>'
    AWS_SECRET_KEY = '<YOUR_SECRET_ACCESS_KEY>'
  )
  FILE_FORMAT = olist_csv_format;

-- Test: list the files Snowflake can see in S3
LIST @olist_s3_stage;