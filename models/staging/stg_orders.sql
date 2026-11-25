select
    order_id,
    customer_id,
    cast(order_date as date) as order_date,
    {{ order_status_label('status') }} as status,
    channel,
    {{ cents_to_dollars('discount_cents') }} as discount_amount
from {{ source('retail', 'raw_orders') }}
