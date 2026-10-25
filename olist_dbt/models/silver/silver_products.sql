-- silver_products: one row per product, with fixed column names and numeric measurements

with source as (
    select * from {{ source('bronze', 'products') }}
),

cleaned as (
    select
        trim(product_id)                                            as product_id,

        -- Missing categories labelled 'unknown' so they still appear in reports
        coalesce(lower(trim(product_category_name)), 'unknown')     as category_name,

        -- Fix misspelled source column names ("lenght")
        try_to_number(product_name_lenght)                          as name_length,
        try_to_number(product_description_lenght)                   as description_length,
        try_to_number(product_photos_qty)                           as photos_qty,

        try_to_number(product_weight_g)                             as weight_g,
        try_to_number(product_length_cm)                            as length_cm,
        try_to_number(product_height_cm)                            as height_cm,
        try_to_number(product_width_cm)                             as width_cm,

        _loaded_at
    from source
)

select * from cleaned