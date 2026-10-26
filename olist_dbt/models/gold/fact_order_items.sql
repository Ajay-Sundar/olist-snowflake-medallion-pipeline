-- fact_order_items: one row per item in an order (order_id + order_item_id)
-- Links to dim_customers, dim_products, dim_sellers and dim_date

with order_items as (
    select * from {{ ref('silver_order_items') }}
),

orders as (
    select * from {{ ref('silver_orders') }}
),

customers as (
    select customer_id, customer_unique_id
    from {{ ref('silver_customers') }}
)

select
    -- Keys
    oi.order_id,
    oi.order_item_id,
    c.customer_unique_id,
    oi.product_id,
    oi.seller_id,
    to_number(to_char(o.order_purchased_at, 'YYYYMMDD'))   as order_date_key,

    -- Context
    o.order_status,
    o.order_purchased_at,

    -- Measures
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value                             as total_item_value
from order_items oi
join orders o
    on oi.order_id = o.order_id
join customers c
    on o.customer_id = c.customer_id