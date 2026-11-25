-- No product should ever carry a negative unit margin at mart level.
select
    product_id,
    unit_price,
    unit_cost,
    unit_margin
from {{ ref('dim_products') }}
where unit_margin < 0
