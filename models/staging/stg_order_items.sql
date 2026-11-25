select
    order_item_id,
    order_id,
    product_id,
    quantity,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price
from {{ source('retail', 'raw_order_items') }}
where quantity > 0
