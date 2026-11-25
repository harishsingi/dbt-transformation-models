select
    customer_id,
    first_name,
    last_name,
    lower(trim(email)) as email,
    cast(signup_date as date) as signup_date,
    region,
    segment,
    cast(is_active as boolean) as is_active,
    cast(updated_at as date) as updated_at
from {{ source('retail', 'raw_customers') }}
