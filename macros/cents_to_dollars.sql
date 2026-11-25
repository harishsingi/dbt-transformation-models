{# Convert an integer cents amount to dollars, rounded to the cent.
   Null in, null out. Cast to double first so integer division can
   never truncate the value. #}
{% macro cents_to_dollars(column_name) %}
    round(cast({{ column_name }} as double) / 100.0, 2)
{% endmacro %}
