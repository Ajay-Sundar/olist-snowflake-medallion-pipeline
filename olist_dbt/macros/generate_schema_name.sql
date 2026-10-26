-- Use the custom schema name exactly as given (e.g. GOLD), instead of
-- dbt's default of joining it to the target schema (e.g. SILVER_GOLD)

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}