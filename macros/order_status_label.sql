{# Unify the status spellings found in raw extracts into the canonical
   set: completed, shipped, cancelled, refunded. Unknown spellings pass
   through lowercased and trimmed, so a new spelling surfaces in the
   accepted_values test on stg_orders instead of being silently dropped.
   Null in, null out. #}
{% macro order_status_label(column_name) %}
    case
        when {{ column_name }} is null then null
        when lower(trim({{ column_name }})) in ('complete', 'done') then 'completed'
        when lower(trim({{ column_name }})) in ('cancel', 'canceled') then 'cancelled'
        when lower(trim({{ column_name }})) in ('refund', 'refunded') then 'refunded'
        else lower(trim({{ column_name }}))
    end
{% endmacro %}
