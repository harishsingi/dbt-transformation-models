{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

-- Snapshot stg_customers, not the raw source: staging casts updated_at
-- to a timestamp, which matches the snapshot's own validity timestamps
-- (snapshotting the raw DATE column raises a type-mismatch warning).
-- History therefore reflects the cleaned values the marts use.
-- Explicit columns (no select *) so a future staging-column change
-- fails loudly instead of silently changing history.
select
    customer_id,
    first_name,
    last_name,
    email,
    signup_date,
    region,
    segment,
    is_active,
    updated_at
from {{ ref('stg_customers') }}

{% endsnapshot %}
