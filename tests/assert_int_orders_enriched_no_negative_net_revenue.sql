-- The discount cap means enriched net revenue can never go negative,
-- for any status, not just fulfilled orders.
select
    order_id,
    status,
    gross_revenue,
    discount_applied,
    net_revenue
from {{ ref('int_orders_enriched') }}
where net_revenue < 0
