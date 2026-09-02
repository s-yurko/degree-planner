{#
  dbt normally prefixes custom schemas as <target>_<schema> (e.g. analytics_staging);
  this override uses +schema as-is, so models land in bare staging/intermediate/marts
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
