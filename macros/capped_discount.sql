{# Cap a discount at the order's gross revenue, floored at zero, so a
   discount can never take net revenue negative (and a negative discount
   can never inflate it). Null discount or gross revenue counts as 0. #}
{% macro capped_discount(gross_revenue, discount_amount) %}
    least(
        greatest(coalesce({{ discount_amount }}, 0), 0),
        greatest(coalesce({{ gross_revenue }}, 0), 0)
    )
{% endmacro %}
