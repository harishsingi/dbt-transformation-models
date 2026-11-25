-- Analysis, not a model: compiled with `dbt compile` and run ad hoc,
-- never materialised. Customer counts and revenue share by value tier.
select
    value_tier,
    count(*) as customers,
    sum(lifetime_revenue) as lifetime_revenue,
    sum(lifetime_revenue) / nullif(sum(sum(lifetime_revenue)) over (), 0) as revenue_share
from {{ ref('dim_customers') }}
group by value_tier
order by lifetime_revenue desc
