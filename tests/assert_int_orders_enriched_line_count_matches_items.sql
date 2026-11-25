-- Every order's line_count must equal its actual line-item count,
-- including 0 for an order with no lines.
select
    o.order_id,
    o.line_count,
    coalesce(i.actual_lines, 0) as actual_lines
from {{ ref('int_orders_enriched') }} o
left join (
    select order_id, count(*) as actual_lines
    from {{ ref('stg_order_items') }}
    group by order_id
) i
    on o.order_id = i.order_id
where o.line_count != coalesce(i.actual_lines, 0)
