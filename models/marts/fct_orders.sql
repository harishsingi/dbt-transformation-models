select
    order_id,
    customer_id,
    order_date,
    status,
    channel,
    line_count,
    total_units,
    gross_revenue,
    total_cost,
    gross_profit,
    discount_amount,
    net_revenue
from {{ ref('int_orders_enriched') }}
where status in ('completed', 'shipped')
