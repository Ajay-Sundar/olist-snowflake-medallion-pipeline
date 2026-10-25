-- silver_geolocation: zip prefix to coordinates, with exact duplicate rows removed
-- A zip prefix covers an area, so it still has many coordinates (grouped to one per zip in Gold)

with source as (
    select * from {{ source('bronze', 'geolocation') }}
),

cleaned as (
    select
        trim(geolocation_zip_code_prefix)       as zip_code_prefix,
        try_to_double(geolocation_lat)          as latitude,
        try_to_double(geolocation_lng)          as longitude,
        lower(trim(geolocation_city))           as city,
        upper(trim(geolocation_state))          as state
    from source
),

-- Remove exact duplicate rows
deduplicated as (
    select distinct * from cleaned
)

select * from deduplicated