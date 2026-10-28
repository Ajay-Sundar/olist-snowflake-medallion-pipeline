# Olist E-Commerce Dashboard (Streamlit in Snowflake)
# Reads from the Gold layer star schema in OLIST_DB.GOLD

import os
import streamlit as st
import altair as alt

st.set_page_config(page_title="Olist E-Commerce Dashboard", layout="wide")

# Connect to Snowflake using the app's built-in connection (no passwords needed)
conn = st.connection("snowflake", ttl=os.getenv("SNOWFLAKE_CONNECTION_TTL"))
session = conn.session()

# Run a query and cache the result for 10 minutes (saves time and credits)
@st.cache_data(ttl=600)
def run_query(sql):
    return session.sql(sql).to_pandas()

st.title("Olist E-Commerce Dashboard")
st.caption("Brazilian e-commerce orders, 2016-2018 · Source: OLIST_DB.GOLD")

# ---------- 1. Headline numbers ----------
kpis = run_query("""
    select
        sum(payment_value)                  as revenue,
        count(*)                            as orders,
        count(distinct customer_unique_id)  as customers,
        sum(payment_value) / count(*)       as avg_order_value
    from OLIST_DB.GOLD.FACT_ORDERS
""")

c1, c2, c3, c4 = st.columns(4)
c1.metric("Revenue (R$)", f"{kpis['REVENUE'][0]:,.0f}")
c2.metric("Orders", f"{kpis['ORDERS'][0]:,}")
c3.metric("Customers", f"{kpis['CUSTOMERS'][0]:,}")
c4.metric("Avg order value (R$)", f"{kpis['AVG_ORDER_VALUE'][0]:,.2f}")

st.divider()

# ---------- 2. Sales over time ----------
st.subheader("Monthly revenue")

monthly = run_query("""
    select
        date_trunc('month', d.date_day)     as order_month,
        sum(f.payment_value)                as revenue,
        count(*)                            as orders
    from OLIST_DB.GOLD.FACT_ORDERS f
    join OLIST_DB.GOLD.DIM_DATE d
        on f.order_date_key = d.date_key
    group by order_month
    order by order_month
""")

st.line_chart(monthly, x="ORDER_MONTH", y="REVENUE")
st.caption("Data is sparse before 2017 and stops in early September 2018, "
           "so the first and last months look low.")\



st.divider()

# ---------- 3 & 4. Top categories and sales by state ----------
left, right = st.columns(2)

with left:
    st.subheader("Top 10 categories by revenue")
    categories = run_query("""
        select
            p.category,
            sum(f.price)            as revenue,
            count(*)                as items_sold
        from OLIST_DB.GOLD.FACT_ORDER_ITEMS f
        join OLIST_DB.GOLD.DIM_PRODUCTS p
            on f.product_id = p.product_id
        group by p.category
        order by revenue desc
        limit 10
    """)
    st.altair_chart(
        alt.Chart(categories).mark_bar().encode(
            x=alt.X("REVENUE:Q", title="Revenue (R$)"),
            y=alt.Y("CATEGORY:N", sort="-x", title=None),
            tooltip=["CATEGORY", "REVENUE", "ITEMS_SOLD"],
        ),
        use_container_width=True,
    )

with right:
    st.subheader("Top 10 states by revenue")
    states = run_query("""
        select
            c.state,
            sum(f.payment_value)    as revenue,
            count(*)                as orders
        from OLIST_DB.GOLD.FACT_ORDERS f
        join OLIST_DB.GOLD.DIM_CUSTOMERS c
            on f.customer_unique_id = c.customer_unique_id
        group by c.state
        order by revenue desc
        limit 10
    """)
    st.altair_chart(
        alt.Chart(states).mark_bar().encode(
            x=alt.X("REVENUE:Q", title="Revenue (R$)"),
            y=alt.Y("STATE:N", sort="-x", title=None),
            tooltip=["STATE", "REVENUE", "ORDERS"],
        ),
        use_container_width=True,
    )


    st.divider()

# ---------- 5. Delivery performance ----------
st.subheader("Delivery performance")

delivery = run_query("""
    select
        avg(delivery_days)                          as avg_delivery_days,
        avg(iff(is_late, 1, 0)) * 100               as pct_late,
        avg(iff(is_late, review_score, null))       as late_review,
        avg(iff(not is_late, review_score, null))   as on_time_review
    from OLIST_DB.GOLD.FACT_ORDERS
    where order_delivered_at is not null
""")

d1, d2, d3, d4 = st.columns(4)
d1.metric("Avg delivery time", f"{delivery['AVG_DELIVERY_DAYS'][0]:.1f} days")
d2.metric("Orders delivered late", f"{delivery['PCT_LATE'][0]:.1f}%")
d3.metric("Avg review: on time", f"{delivery['ON_TIME_REVIEW'][0]:.2f} ★")
d4.metric("Avg review: late", f"{delivery['LATE_REVIEW'][0]:.2f} ★")

lateness = run_query("""
    with delays as (
        select
            datediff(day, order_estimated_delivery_date, order_delivered_at::date) as days_late,
            review_score
        from OLIST_DB.GOLD.FACT_ORDERS
        where order_delivered_at is not null
          and review_score is not null
    )
    select
        case
            when days_late <= 0  then '1. On time'
            when days_late <= 3  then '2. 1-3 days late'
            when days_late <= 7  then '3. 4-7 days late'
            when days_late <= 14 then '4. 8-14 days late'
            else                      '5. 15+ days late'
        end                     as delay_group,
        avg(review_score)       as avg_review,
        count(*)                as orders
    from delays
    group by delay_group
    order by delay_group
""")

st.altair_chart(
    alt.Chart(lateness).mark_bar().encode(
        x=alt.X("DELAY_GROUP:N", title=None, sort=None, axis=alt.Axis(labelAngle=0)),
        y=alt.Y("AVG_REVIEW:Q", title="Average review score (1-5)",
                scale=alt.Scale(domain=[0, 5])),
        tooltip=["DELAY_GROUP", "AVG_REVIEW", "ORDERS"],
    ),
    use_container_width=True,
)
st.caption("Review scores fall sharply once an order is late: even 1-3 days late costs about one full star.")


st.divider()

# ---------- 6. Customer retention ----------
st.subheader("Customer retention")

retention = run_query("""
    select
        avg(iff(is_repeat_customer, 1, 0)) * 100    as pct_repeat,
        count_if(is_repeat_customer)                as repeat_customers,
        min(num_orders)                             as min_orders,
        max(num_orders)                             as max_orders
    from OLIST_DB.GOLD.DIM_CUSTOMERS
""")

r1, r2, r3, r4 = st.columns(4)
r1.metric("Repeat customers", f"{retention['PCT_REPEAT'][0]:.1f}%")
r2.metric("Customers who came back", f"{retention['REPEAT_CUSTOMERS'][0]:,}")
r3.metric("Fewest orders by a customer", f"{retention['MIN_ORDERS'][0]}")
r4.metric("Most orders by a customer", f"{retention['MAX_ORDERS'][0]}")

distribution = run_query("""
    select
        num_orders,
        count(*)    as customers
    from OLIST_DB.GOLD.DIM_CUSTOMERS
    group by num_orders
    order by num_orders
""")

st.markdown("**How many orders do customers place?**")
bars = alt.Chart(distribution).mark_bar().encode(
    x=alt.X("NUM_ORDERS:O", title="Orders placed", axis=alt.Axis(labelAngle=0)),
    y=alt.Y("CUSTOMERS:Q", title="Customers (log scale)",
        scale=alt.Scale(type="symlog"),
        axis=alt.Axis(values=[1, 10, 100, 1000, 10000, 100000], format=",")),
    tooltip=["NUM_ORDERS", "CUSTOMERS"],
)
labels = bars.mark_text(dy=-8, color="white").encode(
    text=alt.Text("CUSTOMERS:Q", format=",")
)
st.altair_chart(bars + labels, use_container_width=True)
st.caption("Most customers order only once. The chart uses a log scale so the small "
           "groups of repeat customers are still visible.")