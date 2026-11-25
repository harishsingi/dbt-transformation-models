select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.signup_date,
    c.region,
    c.segment,
    c.is_active,
    coalesce(h.order_count, 0) as order_count,
    h.first_order_date,
    h.most_recent_order_date,
    coalesce(h.lifetime_revenue, 0) as lifetime_revenue,
    coalesce(h.cancelled_orders, 0) as cancelled_orders,
    coalesce(h.refunded_orders, 0) as refunded_orders,
    case
        when coalesce(h.lifetime_revenue, 0) >= 1000 then 'high_value'
        when coalesce(h.lifetime_revenue, 0) >= 250 then 'mid_value'
        when coalesce(h.order_count, 0) > 0 then 'low_value'
        else 'never_ordered'
    end as value_tier
from {{ ref('stg_customers') }} c
left join {{ ref('int_customer_order_history') }} h
    on c.customer_id = h.customer_id
