-- Analysis, not a model: compiled with `dbt compile` and run ad hoc,
-- never materialised. Revenue and margin by product category over
-- fulfilled orders only.
select
    p.category,
    count(distinct o.order_id) as orders,
    sum(oi.quantity) as units_sold,
    sum(oi.quantity * oi.unit_price) as gross_revenue,
    sum(oi.quantity * oi.unit_price) - sum(oi.quantity * p.unit_cost) as gross_profit
from {{ ref('stg_order_items') }} oi
join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id
join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id
where o.status in {{ fulfilled_statuses_list() }}
group by p.category
order by gross_revenue desc
