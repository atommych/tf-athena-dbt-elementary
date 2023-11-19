{% macro render_from_context(name) -%}
{% set original_name = name %}
  {% if '.' in name %}
  {% set package_name, name = name.split(".", 1) %}
  {% else %}
  {% set package_name = none %}
  {% endif %}

  {% if package_name is none %}
  {% set package_context = context %}
  {% elif package_name in context %}
  {% set package_context = context[package_name] %}
  {% else %}
  {% set error_msg %}
    Could not find package '{{package_name}}', called with '{{original_name}}'
  {% endset %}
  {{ exceptions.raise_compiler_error(error_msg | trim) }}
  {% endif %}
  
  {{ return(package_context[name](*varargs, **kwargs)) }}

{%- endmacro %}

{% macro refresh_external_table_ddl(source_node) %}
  {{ return(adapter.dispatch('refresh_external_table_ddl')(source_node)) }}
{% endmacro %}

{% macro default__refresh_external_table_ddl(source_node) %}
  {{ exceptions.raise_compiler_error("External table creation is not implemented for the default adapter") }}
{% endmacro %}

{% macro athena__refresh_external_table_ddl(source_node) %}

  {%- set starting = [
    {
      'partition_by': [],
      'path': ''
    }
  ] -%}

  {%- set ending = [] -%}
  {%- set finals = [] -%}
  
  {%- set partitions = source_node.external.get('partitions',[]) -%}

  {%- if partitions -%}{%- for partition in partitions -%}
  
    {%- if not loop.first -%}
      {%- set starting = ending -%}
      {%- set ending = [] -%}
    {%- endif -%}
    
    {%- for preexisting in starting -%}
      
      {%- if partition.vals.macro -%}
        {%- set vals = render_from_context(partition.vals.macro, **partition.vals.args) -%}
      {%- elif partition.vals is string -%}
        {%- set vals = [partition.vals] -%}
      {%- else -%}
        {%- set vals = partition.vals -%}
      {%- endif -%}
      
      {# Allow the use of custom 'key' in path_macro (path.sql) #}
      {# By default, take value from source node 'external.partitions.name' from raw yml #}
      {# Useful if the data in s3 is saved with a prefix/suffix path 'path_macro_key' other than 'external.partitions.name' #}
      {%- if partition.path_macro_key -%}
        {%- set path_macro_key = partition.path_macro_key -%}
      {%- else -%}
        {%- set path_macro_key = partition.name -%}
      {%- endif -%}
    
      {%- for val in vals -%}
      
        {# For each preexisting guy, add a new one #}
      
        {%- set next_partition_by = [] -%}
        
        {%- for prexist_part in preexisting.partition_by -%}
          {%- do next_partition_by.append(prexist_part) -%}
        {%- endfor -%}
        
        {%- do next_partition_by.append({'name': partition.name, 'value': val}) -%}

        {# Concatenate path #}

        {%- set concat_path = preexisting.path ~ render_from_context(partition.path_macro, path_macro_key, val) -%}
        
        {%- do ending.append({'partition_by': next_partition_by, 'path': concat_path}) -%}
      
      {%- endfor -%}
      
    {%- endfor -%}
    
    {%- if loop.last -%}
      {%- for end in ending -%}
        {%- do finals.append(end) -%}
      {%- endfor -%}
    {%- endif -%}
    
  {%- endfor -%}
  
    {%- set ddl = alter_table_add_partitions_ddl(source_node, finals) -%}
    {{ return(ddl) }}
  
  {% else %}
  
    {% do return([]) %}
  
  {% endif %}
  
{% endmacro %}
