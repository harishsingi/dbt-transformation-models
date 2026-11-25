{{ config(materialized='view') }}

select
    product_id,
    trim(product_name) as product_name,
    trim(category) as category,
    trim(subcategory) as subcategory,
    {{ cents_to_dollars('unit_cost_cents') }} as unit_cost,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    cast(is_active as boolean) as is_active
from {{ source('retail', 'raw_products') }}
