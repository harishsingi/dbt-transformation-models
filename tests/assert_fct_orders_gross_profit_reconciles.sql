-- Arithmetic inside fct_orders must hold on every row: profit is
-- revenue minus cost, net is revenue minus the discount actually
-- applied, and the applied discount never exceeds gross revenue or
-- the raw discount. A 1-cent tolerance absorbs float rounding.
select
    order_id,
    gross_revenue,
    total_cost,
    gross_profit,
    discount_amount,
    discount_applied,
    net_revenue
from {{ ref('fct_orders') }}
where abs(gross_profit - (gross_revenue - total_cost)) > 0.01
    or abs(net_revenue - (gross_revenue - discount_applied)) > 0.01
    or discount_applied > gross_revenue + 0.01
    or discount_applied > discount_amount + 0.01
