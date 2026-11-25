select
    product_id,
    product_name,
    category,
    subcategory,
    {{ cents_to_dollars('unit_cost_cents') }} as unit_cost,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    cast(is_active as boolean) as is_active
from {{ source('retail', 'raw_products') }}
