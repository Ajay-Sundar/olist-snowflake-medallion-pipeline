-- silver_payments: one row per payment within an order (order_id + payment_sequential)

with source as (
    select * from {{ source('bronze', 'payments') }}
),

cleaned as (
    select
        trim(order_id)                              as order_id,
        try_to_number(payment_sequential)           as payment_sequential,
        lower(trim(payment_type))                   as payment_type,
        try_to_number(payment_installments)         as payment_installments,

        -- Money as exact decimals (2 decimal places)
        try_to_number(payment_value, 10, 2)         as payment_value,

        _loaded_at
    from source
)

select * from cleaned