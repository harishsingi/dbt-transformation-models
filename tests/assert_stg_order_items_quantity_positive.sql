-- Staging filters out lines with quantity <= 0, so none should remain.
select
    order_item_id,
    quantity
from {{ ref('stg_order_items') }}
where quantity <= 0
