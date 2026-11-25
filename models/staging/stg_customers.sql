{{ config(materialized='view') }}

select
    customer_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    lower(trim(email)) as email,
    cast(signup_date as date) as signup_date,
    trim(region) as region,
    trim(segment) as segment,
    cast(is_active as boolean) as is_active,
    -- Keep the full timestamp (not a date cast): the snapshot strategy
    -- keys off updated_at, and truncating it would hide same-day changes.
    cast(updated_at as timestamp) as updated_at
from {{ source('retail', 'raw_customers') }}
