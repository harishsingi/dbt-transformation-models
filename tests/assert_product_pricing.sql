-- No product should ever be priced below its cost.
select
    product_id,
    unit_price,
    unit_cost
from {{ ref('stg_products') }}
where unit_price < unit_cost
