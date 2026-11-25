select
    customer_id,
    count(*) as order_count,
    min(order_date) as first_order_date,
    max(order_date) as most_recent_order_date,
    sum(case when status in ('completed', 'shipped') then net_revenue else 0 end)
        as lifetime_revenue,
    sum(case when status = 'cancelled' then 1 else 0 end) as cancelled_orders,
    sum(case when status = 'refunded' then 1 else 0 end) as refunded_orders
from {{ ref('int_orders_enriched') }}
group by customer_id
