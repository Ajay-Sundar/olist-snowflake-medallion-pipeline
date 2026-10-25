-- silver_category_translation: lookup of Portuguese product category names to English

with source as (
    select * from {{ source('bronze', 'category_translation') }}
),

cleaned as (
    select
        lower(trim(product_category_name))              as category_name,
        lower(trim(product_category_name_english))      as category_name_english,

        _loaded_at
    from source
)

select * from cleaned