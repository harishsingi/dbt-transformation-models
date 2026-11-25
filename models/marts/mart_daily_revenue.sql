{{ config(materialized='table') }}

-- No ORDER BY here: a table model has no guaranteed row order, and
-- downstream queries sort for presentation. Keeping the sort out also
-- keeps the model deterministic for tests that compare full outputs.
select
    order_date,
    count(*) as orders,
    sum(total_units) as units_sold,
    sum(gross_revenue) as gross_revenue,
    sum(gross_profit) as gross_profit,
    sum(net_revenue) as net_revenue,
    sum(net_revenue) / nullif(count(*), 0) as avg_order_value,
    sum(gross_profit) / nullif(sum(gross_revenue), 0) as gross_margin_pct
from {{ ref('fct_orders') }}
group by order_date
