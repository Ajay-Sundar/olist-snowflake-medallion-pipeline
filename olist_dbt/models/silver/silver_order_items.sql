-- silver_order_items: one row per product in an order, with proper numeric and timestamp types

with source as (
    select * from {{ source('bronze', 'order_items') }}
),

cleaned as (
    select
        trim(order_id)                              as order_id,
        try_to_number(order_item_id)                as order_item_id,
        trim(product_id)                            as product_id,
        trim(seller_id)                             as seller_id,
        try_to_timestamp(shipping_limit_date)       as shipping_limit_at,

        -- Money as exact decimals (2 decimal places)
        try_to_number(price, 10, 2)                 as price,
        try_to_number(freight_value, 10, 2)         as freight_value,

        _loaded_at
    from source
)

select * from cleaned