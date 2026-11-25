{{ config(materialized='view') }}

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price
from {{ source('retail', 'raw_order_items') }}
-- Invalid lines (zero or negative quantity) never reach a mart; the
-- singular test assert_stg_order_items_quantity_positive guards this.
where quantity > 0
