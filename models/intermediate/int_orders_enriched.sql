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
        oi.quantity * p.unit_cost as line_cost
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_products') }} p
        on oi.product_id = p.product_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.channel,
    o.discount_amount,
    count(*) as line_count,
    sum(li.quantity) as total_units,
    sum(li.line_revenue) as gross_revenue,
    sum(li.line_cost) as total_cost,
    sum(li.line_revenue) - sum(li.line_cost) as gross_profit,
    -- A discount can never take an order below zero: cap it at gross revenue.
    sum(li.line_revenue)
        - least(o.discount_amount, coalesce(sum(li.line_revenue), 0)) as net_revenue
from {{ ref('stg_orders') }} o
left join line_items li
    on o.order_id = li.order_id
group by
    o.order_id, o.customer_id, o.order_date,
    o.status, o.channel, o.discount_amount
