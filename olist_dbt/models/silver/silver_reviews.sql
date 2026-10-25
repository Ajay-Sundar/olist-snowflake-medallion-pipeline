-- silver_reviews: one row per review per order (review_id + order_id)
-- A review_id can appear on multiple orders when one review covers several orders

with source as (
    select * from {{ source('bronze', 'reviews') }}
),

cleaned as (
    select
        trim(review_id)                             as review_id,
        trim(order_id)                              as order_id,
        try_to_number(review_score)                 as review_score,

        -- Most customers leave no comment, so these are often NULL
        trim(review_comment_title)                  as review_title,
        trim(review_comment_message)                as review_message,

        try_to_timestamp(review_creation_date)      as review_created_at,
        try_to_timestamp(review_answer_timestamp)   as review_answered_at,

        _loaded_at
    from source
)

select * from cleaned