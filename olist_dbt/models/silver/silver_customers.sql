-- silver_customers: one row per customer_id (per order), with cleaned location fields
-- customer_unique_id identifies the real person across multiple orders

with source as (
    select * from {{ source('bronze', 'customers') }}
),

cleaned as (
    select
        trim(customer_id)                   as customer_id,
        trim(customer_unique_id)            as customer_unique_id,

        -- Zip kept as text to preserve leading zeros
        trim(customer_zip_code_prefix)      as zip_code_prefix,
        lower(trim(customer_city))          as city,
        upper(trim(customer_state))         as state,

        _loaded_at
    from source
)

select * from cleaned