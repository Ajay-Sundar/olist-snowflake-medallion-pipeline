-- NOTE: Not in use. This is the preferred, more secure method (IAM role),
-- but it was blocked on the AWS Free plan. Kept for reference.
-- The project uses access keys instead (see 03_file_format_stage.sql).

-- 01_storage_integration.sql
-- Purpose: Securely connect Snowflake to the S3 bucket holding the raw CSV files

-- Create the connection using the AWS role (no passwords or keys stored)
-- Only allowed to access this one bucket
CREATE OR REPLACE STORAGE INTEGRATION olist_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::890028163073:role/snowflake-olist-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://ajay-olist-ecommerce-raw/');

-- Show the user ARN and external ID to add to the AWS role's trust policy
-- Note: re-running CREATE OR REPLACE generates a new external ID
DESC INTEGRATION olist_s3_integration;