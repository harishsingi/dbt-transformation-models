-- dim_customers.lifetime_revenue must equal the sum of fct_orders
-- net revenue for that customer (0 for customers with no fulfilled
-- orders). Amounts are rounded to cents on both sides so floating
-- point addition cannot fail the comparison.
select
    d.customer_id,
    d.lifetime_revenue,
    coalesce(f.fact_revenue, 0) as fact_revenue
from {{ ref('dim_customers') }} d
left join (
    select customer_id, sum(net_revenue) as fact_revenue
    from {{ ref('fct_orders') }}
    group by customer_id
) f
    on d.customer_id = f.customer_id
where round(d.lifetime_revenue, 2) != round(coalesce(f.fact_revenue, 0), 2)
