-- 04_bronze_tables.sql
-- Purpose: Create Bronze tables to hold the raw CSV data exactly as received
-- All columns are VARCHAR so loads never fail; types are fixed in the Silver layer
-- _source_file and _loaded_at track where and when each row came from

USE SCHEMA OLIST_DB.BRONZE;

CREATE OR REPLACE TABLE orders (
  order_id                       VARCHAR,
  customer_id                    VARCHAR,
  order_status                   VARCHAR,
  order_purchase_timestamp       VARCHAR,
  order_approved_at              VARCHAR,
  order_delivered_carrier_date   VARCHAR,
  order_delivered_customer_date  VARCHAR,
  order_estimated_delivery_date  VARCHAR,
  _source_file                   VARCHAR,
  _loaded_at                     TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE order_items (
  order_id             VARCHAR,
  order_item_id        VARCHAR,
  product_id           VARCHAR,
  seller_id            VARCHAR,
  shipping_limit_date  VARCHAR,
  price                VARCHAR,
  freight_value        VARCHAR,
  _source_file         VARCHAR,
  _loaded_at           TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE customers (
  customer_id               VARCHAR,
  customer_unique_id        VARCHAR,
  customer_zip_code_prefix  VARCHAR,
  customer_city             VARCHAR,
  customer_state            VARCHAR,
  _source_file              VARCHAR,
  _loaded_at                TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE products (
  product_id                  VARCHAR,
  product_category_name       VARCHAR,
  product_name_lenght         VARCHAR,
  product_description_lenght  VARCHAR,
  product_photos_qty          VARCHAR,
  product_weight_g            VARCHAR,
  product_length_cm           VARCHAR,
  product_height_cm           VARCHAR,
  product_width_cm            VARCHAR,
  _source_file                VARCHAR,
  _loaded_at                  TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE sellers (
  seller_id               VARCHAR,
  seller_zip_code_prefix  VARCHAR,
  seller_city             VARCHAR,
  seller_state            VARCHAR,
  _source_file            VARCHAR,
  _loaded_at              TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE payments (
  order_id              VARCHAR,
  payment_sequential    VARCHAR,
  payment_type          VARCHAR,
  payment_installments  VARCHAR,
  payment_value         VARCHAR,
  _source_file          VARCHAR,
  _loaded_at            TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE reviews (
  review_id                VARCHAR,
  order_id                 VARCHAR,
  review_score             VARCHAR,
  review_comment_title     VARCHAR,
  review_comment_message   VARCHAR,
  review_creation_date     VARCHAR,
  review_answer_timestamp  VARCHAR,
  _source_file             VARCHAR,
  _loaded_at               TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE geolocation (
  geolocation_zip_code_prefix  VARCHAR,
  geolocation_lat              VARCHAR,
  geolocation_lng              VARCHAR,
  geolocation_city             VARCHAR,
  geolocation_state            VARCHAR,
  _source_file                 VARCHAR,
  _loaded_at                   TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE category_translation (
  product_category_name          VARCHAR,
  product_category_name_english  VARCHAR,
  _source_file                   VARCHAR,
  _loaded_at                     TIMESTAMP_NTZ
);