{% macro order_status_label(column_name) %}
    case lower(trim({{ column_name }}))
        when 'complete' then 'completed'
        when 'done' then 'completed'
        when 'cancel' then 'cancelled'
        when 'refund' then 'refunded'
        else lower(trim({{ column_name }}))
    end
{% endmacro %}
