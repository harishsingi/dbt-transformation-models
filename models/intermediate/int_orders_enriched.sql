{{ config(materialized='ephemeral') }}

with line_items as (
    select
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.quantity * oi.unit_price as line_revenue,
        p.category,
        p.subcategory,
        p.unit_cost,
        -- A line whose product is missing has no known cost. Count it
        -- separately (unknown_product_lines) instead of silently
        -- treating it as free; the relationships test on product_id
        -- should keep this at zero on clean data.
        coalesce(oi.quantity * p.unit_cost, 0) as line_cost,
        case when p.product_id is null then 1 else 0 end as is_unknown_product
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_products') }} p
        on oi.product_id = p.product_id
),

order_totals as (
    select
        order_id,
        count(*) as line_count,
        sum(quantity) as total_units,
        sum(line_revenue) as gross_revenue,
        sum(line_cost) as total_cost,
        sum(is_unknown_product) as unknown_product_lines
    from line_items
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.channel,
    o.discount_amount,
    -- count(t.order_id), not count(*): an order with no lines must
    -- report 0 lines and 0 revenue, not 1 line and null revenue.
    coalesce(t.line_count, 0) as line_count,
    coalesce(t.total_units, 0) as total_units,
    coalesce(t.gross_revenue, 0) as gross_revenue,
    coalesce(t.total_cost, 0) as total_cost,
    coalesce(t.gross_revenue, 0) - coalesce(t.total_cost, 0) as gross_profit,
    coalesce(t.unknown_product_lines, 0) as unknown_product_lines,
    -- A discount can never take an order below zero: cap it at gross
    -- revenue (see macros/capped_discount.sql) and keep the applied
    -- amount visible so the cap is auditable, not hidden.
    {{ capped_discount('coalesce(t.gross_revenue, 0)', 'o.discount_amount') }} as discount_applied,
    coalesce(t.gross_revenue, 0)
        - {{ capped_discount('coalesce(t.gross_revenue, 0)', 'o.discount_amount') }} as net_revenue
from {{ ref('stg_orders') }} o
left join order_totals t
    on o.order_id = t.order_id
