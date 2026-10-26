-- dim_products: one row per product, with English category names
-- Falls back to the Portuguese name when no translation exists

with products as (
    select * from {{ ref('silver_products') }}
),

translations as (
    select * from {{ ref('silver_category_translation') }}
)

select
    p.product_id,
    coalesce(t.category_name_english, p.category_name)     as category,
    p.category_name                                         as category_portuguese,
    p.weight_g,
    p.length_cm,
    p.height_cm,
    p.width_cm,
    p.photos_qty
from products p
left join translations t
    on p.category_name = t.category_name