{{ config(materialized='table') }}

select
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_cost,
    p.unit_price,
    p.unit_price - p.unit_cost as unit_margin,
    -- Margin as a share of price; null when the price is 0, never a
    -- divide-by-zero error.
    (p.unit_price - p.unit_cost) / nullif(p.unit_price, 0) as unit_margin_pct,
    p.is_active
from {{ ref('stg_products') }} p
