{% macro clean_string(column_name) -%}
    nullif(trim({{ column_name }}), '')
{%- endmacro %}


{% macro yn_to_bool(column_name) -%}
    coalesce(nullif(trim({{ column_name }}), '') ilike 'yes', false)
{%- endmacro %}
