select
    order_date,
    count(*) as orders,
    sum(total_units) as units_sold,
    sum(gross_revenue) as gross_revenue,
    sum(gross_profit) as gross_profit,
    sum(net_revenue) as net_revenue,
    sum(net_revenue) / nullif(count(*), 0) as avg_order_value
from {{ ref('fct_orders') }}
group by order_date
order by order_date
