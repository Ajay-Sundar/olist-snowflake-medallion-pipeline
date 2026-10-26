-- dim_customers: one row per real person (customer_unique_id)
-- Location is taken from their most recent order; includes order history summary

with customers as (
    select * from {{ ref('silver_customers') }}
),

orders as (
    select customer_id, order_purchased_at
    from {{ ref('silver_orders') }}
),

-- Attach each customer_id's order date
customer_orders as (
    select
        c.customer_unique_id,
        c.zip_code_prefix,
        c.city,
        c.state,
        o.order_purchased_at
    from customers c
    join orders o
        on c.customer_id = o.customer_id
),

-- Most recent location per person
latest_location as (
    select customer_unique_id, zip_code_prefix, city, state
    from customer_orders
    qualify row_number() over (
        partition by customer_unique_id
        order by order_purchased_at desc
    ) = 1
),

-- Order history per person
order_summary as (
    select
        customer_unique_id,
        min(order_purchased_at)     as first_order_at,
        max(order_purchased_at)     as last_order_at,
        count(*)                    as num_orders
    from customer_orders
    group by customer_unique_id
),

-- One point per zip (average of its coordinates)
zip_centres as (
    select
        zip_code_prefix,
        avg(latitude)   as latitude,
        avg(longitude)  as longitude
    from {{ ref('silver_geolocation') }}
    group by zip_code_prefix
)

select
    l.customer_unique_id,
    l.zip_code_prefix,
    l.city,
    l.state,
    z.latitude,
    z.longitude,
    s.first_order_at,
    s.last_order_at,
    s.num_orders,
    s.num_orders > 1        as is_repeat_customer
from latest_location l
join order_summary s
    on l.customer_unique_id = s.customer_unique_id
left join zip_centres z
    on l.zip_code_prefix = z.zip_code_prefix