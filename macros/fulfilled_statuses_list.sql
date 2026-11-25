{# Render the fulfilled-status list from dbt_project.yml vars as a SQL
   IN-list, e.g. ('completed', 'shipped'), so every model that defines
   "fulfilled" reads the same list from the same place. #}
{% macro fulfilled_statuses_list() -%}
({%- for status in var('fulfilled_statuses') -%}
'{{ status }}'{%- if not loop.last -%}, {% endif -%}
{%- endfor -%})
{%- endmacro %}
