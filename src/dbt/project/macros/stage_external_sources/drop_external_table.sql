{% macro dropif_ddl(source_node) %}
  {{ adapter.dispatch('dropif_ddl')(source_node) }}
{% endmacro %}

{% macro default__dropif_ddl(source_node) %}
  {{ exceptions.raise_compiler_error("External table creation is not implemented for the default adapter") }}
{% endmacro %}


{% macro athena__dropif_ddl(node) %}
  {% set ddl %}
    drop table if exists {{source(node.source_name, node.name)}}
  {% endset %}
  {{return(ddl)}}
{% endmacro %}
