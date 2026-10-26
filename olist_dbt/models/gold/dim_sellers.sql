-- dim_sellers: one row per seller, with approximate map coordinates
-- Geolocation has many points per zip, so we average them to one point per zip first

with sellers as (
    select * from {{ ref('silver_sellers') }}
),

zip_centres as (
    -- One row per zip: the average of all its coordinates
    select
        zip_code_prefix,
        avg(latitude)   as latitude,
        avg(longitude)  as longitude
    from {{ ref('silver_geolocation') }}
    group by zip_code_prefix
)

select
    s.seller_id,
    s.zip_code_prefix,
    s.city,
    s.state,
    z.latitude,
    z.longitude
from sellers s
left join zip_centres z
    on s.zip_code_prefix = z.zip_code_prefix