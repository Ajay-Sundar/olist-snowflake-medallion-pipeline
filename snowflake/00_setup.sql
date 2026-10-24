-- 00_setup.sql
-- Purpose: Set up compute and cost controls for the project

-- Use the smallest warehouse and turn it off after 60 seconds of no use
ALTER WAREHOUSE SNOWFLAKE_LEARNING_WH SET WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60;

-- Spending limit: warn at 80%, stop warehouses at 100%
CREATE OR REPLACE RESOURCE MONITOR TRIAL_MONITOR
  WITH CREDIT_QUOTA = 100
  TRIGGERS ON 80 PERCENT DO NOTIFY
           ON 100 PERCENT DO SUSPEND;

-- Switch the spending limit on for the whole account
ALTER ACCOUNT SET RESOURCE_MONITOR = TRIAL_MONITOR;