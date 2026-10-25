-- silver_sellers: one row per seller, with cleaned location fields

with source as (
    select * from {{ source('bronze', 'sellers') }}
),

cleaned as (
    select
        trim(seller_id)                     as seller_id,

        -- Zip kept as text to preserve leading zeros
        trim(seller_zip_code_prefix)        as zip_code_prefix,
        lower(trim(seller_city))            as city,
        upper(trim(seller_state))           as state,

        _loaded_at
    from source
)

select * from cleaned