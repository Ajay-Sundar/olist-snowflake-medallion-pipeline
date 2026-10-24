-- 02_database_schemas.sql
-- Purpose: Create the project database and the medallion layers

-- Main database for the project
CREATE DATABASE IF NOT EXISTS OLIST_DB;

-- Medallion layers: raw -> cleaned -> business-ready
CREATE SCHEMA IF NOT EXISTS OLIST_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS OLIST_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS OLIST_DB.GOLD;