-- silver_orders: cleaned orders with proper timestamp types and clear column names

with source as (
    select * from {{ source('bronze', 'orders') }}
),

cleaned as (
    select
        trim(order_id)                                       as order_id,
        trim(customer_id)                                    as customer_id,
        lower(trim(order_status))                            as order_status,

        -- Convert text to timestamps (TRY_ returns NULL instead of failing on bad values)
        try_to_timestamp(order_purchase_timestamp)           as order_purchased_at,
        try_to_timestamp(order_approved_at)                  as order_approved_at,
        try_to_timestamp(order_delivered_carrier_date)       as order_shipped_at,
        try_to_timestamp(order_delivered_customer_date)      as order_delivered_at,
        try_to_timestamp(order_estimated_delivery_date)::date as order_estimated_delivery_date,

        _loaded_at
    from source
)

select * from cleaned