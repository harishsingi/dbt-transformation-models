{{ config(materialized='table') }}

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
    gross_profit / nullif(gross_revenue, 0) as gross_margin_pct,
    discount_amount,
    discount_applied,
    net_revenue,
    unknown_product_lines
from {{ ref('int_orders_enriched') }}
where status in {{ fulfilled_statuses_list() }}
