-- dim_date: one row per calendar day (2016-2018), covering the full Olist order period

with day_numbers as (
    -- Generate 1,096 rows numbered 0 to 1095 (one per day)
    select row_number() over (order by seq4()) - 1 as day_offset
    from table(generator(rowcount => 1096))
),

dates as (
    select dateadd(day, day_offset, '2016-01-01'::date) as date_day
    from day_numbers
)

select
    to_number(to_char(date_day, 'YYYYMMDD'))    as date_key,       -- e.g. 20171002
    date_day,
    year(date_day)                              as year,
    quarter(date_day)                           as quarter,
    month(date_day)                             as month,
    monthname(date_day)                         as month_name,     -- e.g. Oct
    day(date_day)                               as day_of_month,
    dayofweekiso(date_day)                      as day_of_week,    -- 1 = Monday ... 7 = Sunday
    dayname(date_day)                           as day_name,       -- e.g. Mon
    dayofweekiso(date_day) in (6, 7)            as is_weekend
from dates