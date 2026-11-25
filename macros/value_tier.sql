{# Customer value tier from lifetime fulfilled revenue and order count.
   Thresholds come from dbt_project.yml vars, so the cutoffs change in
   one place. A customer with orders but low revenue is low_value; a
   customer with no orders at all is never_ordered. #}
{% macro value_tier(lifetime_revenue, order_count) %}
    case
        when coalesce({{ lifetime_revenue }}, 0) >= {{ var('value_tier_high_threshold') }} then 'high_value'
        when coalesce({{ lifetime_revenue }}, 0) >= {{ var('value_tier_mid_threshold') }} then 'mid_value'
        when coalesce({{ order_count }}, 0) > 0 then 'low_value'
        else 'never_ordered'
    end
{% endmacro %}
