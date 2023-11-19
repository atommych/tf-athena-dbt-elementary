{% macro create_schema_ddl(schema_name) %}
    create schema if not exists {{schema_name}}
{% endmacro %}

{% macro create_external_table_ddl(source_node) %}
  {{ adapter.dispatch('create_external_table_ddl')(source_node) }}
{% endmacro %}

{% macro default__create_external_table_ddl(source_node) %}
  {{ exceptions.raise_compiler_error("External table creation is not implemented for the default adapter") }}
{% endmacro %}

{% macro athena__create_external_table_ddl(source_node) %}

  {%- set columns = source_node.columns.values() -%}
  {%- set external = source_node.external -%}
  {%- set partitions = external.partitions -%}

  create external table if not exists {{source(source_node.source_name, source_node.name)| replace('\"', '') }}  (
    {% for column in columns %}
        {{'`' + column.name + '`'}} {{column.data_type}}
        {{- ',' if not loop.last -}}
    {% endfor %}
  )
  {% if partitions -%} partitioned by (
    {%- for partition in partitions -%}
        {{'`' + partition.name + '`'}} {{partition.data_type}}{{', ' if not loop.last}}
    {%- endfor -%}
  ) {%- endif %}
  {% if external.row_format -%} row format {{external.row_format}} {%- endif %}
  {% if external.file_format -%} stored as {{external.file_format}} {%- endif %}
  {% if external.location -%} location '{{external.location}}' {%- endif %}
  {% if external.table_properties -%} tblproperties {{external.table_properties}} {%- endif %}
    
{% endmacro %}
