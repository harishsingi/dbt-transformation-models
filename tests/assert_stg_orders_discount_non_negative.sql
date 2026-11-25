-- A raw discount is never negative. Returns rows only if bad data arrives.
select
    order_id,
    discount_amount
from {{ ref('stg_orders') }}
where discount_amount < 0
