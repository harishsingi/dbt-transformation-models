-- The daily mart must reconcile exactly to the fact table it rolls up.
select
    m.order_date,
    m.orders,
    m.net_revenue as mart_net_revenue,
    f.fact_orders,
    f.fact_net_revenue
from {{ ref('mart_daily_revenue') }} m
left join (
    select
        order_date,
        count(*) as fact_orders,
        sum(net_revenue) as fact_net_revenue
    from {{ ref('fct_orders') }}
    group by order_date
) f
    on m.order_date = f.order_date
where m.orders != f.fact_orders
    or round(m.net_revenue, 2) != round(f.fact_net_revenue, 2)
