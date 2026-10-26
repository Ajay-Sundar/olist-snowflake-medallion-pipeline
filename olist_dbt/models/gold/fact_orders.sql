-- fact_orders: one row per order, with totals, payment, review and delivery performance
-- Items, payments and reviews are summarised per order BEFORE joining to avoid fan-out

with orders as (
    select * from {{ ref('silver_orders') }}
),

customers as (
    select customer_id, customer_unique_id
    from {{ ref('silver_customers') }}
),

items_per_order as (
    select
        order_id,
        count(*)                as num_items,
        sum(price)              as items_value,
        sum(freight_value)      as freight_value
    from {{ ref('silver_order_items') }}
    group by order_id
),

payments_per_order as (
    select
        order_id,
        sum(payment_value)          as payment_value,
        max(payment_installments)   as max_installments,
        count(*)                    as num_payments
    from {{ ref('silver_payments') }}
    group by order_id
),

reviews_per_order as (
    select
        order_id,
        avg(review_score)   as review_score
    from {{ ref('silver_reviews') }}
    group by order_id
)

select
    -- Keys
    o.order_id,
    c.customer_unique_id,
    to_number(to_char(o.order_purchased_at, 'YYYYMMDD'))   as order_date_key,

    -- Order details
    o.order_status,
    o.order_purchased_at,
    o.order_delivered_at,
    o.order_estimated_delivery_date,

    -- Measures (0 when an order has no items or payments)
    coalesce(i.num_items, 0)                    as num_items,
    coalesce(i.items_value, 0)                  as items_value,
    coalesce(i.freight_value, 0)                as freight_value,
    coalesce(p.payment_value, 0)                as payment_value,
    p.max_installments,
    r.review_score,

    -- Delivery performance (NULL if not delivered)
    datediff(day, o.order_purchased_at, o.order_delivered_at)          as delivery_days,
    o.order_delivered_at::date > o.order_estimated_delivery_date       as is_late
from orders o
join customers c
    on o.customer_id = c.customer_id
left join items_per_order i
    on o.order_id = i.order_id
left join payments_per_order p
    on o.order_id = p.order_id
left join reviews_per_order r
    on o.order_id = r.order_id