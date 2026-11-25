{# Use the custom schema name exactly as written (e.g. seeds land in
   schema "raw"), instead of dbt-duckdb's default of prefixing it with
   the target schema ("main_raw"). #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
