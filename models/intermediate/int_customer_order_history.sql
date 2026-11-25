{{ config(materialized='ephemeral') }}

select
    customer_id,
    count(*) as order_count,
    sum(case when status in {{ fulfilled_statuses_list() }} then 1 else 0 end)
        as fulfilled_order_count,
    min(order_date) as first_order_date,
    max(order_date) as most_recent_order_date,
    -- Lifetime value counts fulfilled orders only; cancelled and
    -- refunded orders contribute 0, they are not subtracted.
    sum(case when status in {{ fulfilled_statuses_list() }} then net_revenue else 0 end)
        as lifetime_revenue,
    sum(case when status in {{ fulfilled_statuses_list() }} then net_revenue else 0 end)
        / nullif(sum(case when status in {{ fulfilled_statuses_list() }} then 1 else 0 end), 0)
        as avg_fulfilled_order_value,
    sum(case when status = 'cancelled' then 1 else 0 end) as cancelled_orders,
    sum(case when status = 'refunded' then 1 else 0 end) as refunded_orders
from {{ ref('int_orders_enriched') }}
group by customer_id
