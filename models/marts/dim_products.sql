select
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_cost,
    p.unit_price,
    p.unit_price - p.unit_cost as unit_margin,
    p.is_active
from {{ ref('stg_products') }} p
