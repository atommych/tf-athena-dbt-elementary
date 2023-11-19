{% macro get_external_build_plan(source_node) %}
  {{ return(adapter.dispatch('get_external_build_plan')(source_node)) }}
{% endmacro %}

{% macro default__get_external_build_plan(source_node) %}
  {{ exceptions.raise_compiler_error("Staging external sources is not implemented for the default adapter") }}
{% endmacro %}

{% macro athena__get_external_build_plan(source_node) %}

  {% set build_plan = [] %}
  
  {%- set partitions = source_node.external.get('partitions', none) -%}
  {% set full_refresh = var('full_refresh', false) %}
  
  {% if full_refresh %}

    {% set build_plan = [
        create_schema_ddl(source_node.schema),
        dropif_ddl(source_node),
        create_external_table_ddl(source_node)
      ] + refresh_external_table_ddl(source_node) 
    %}
    
  {% else %}
  
    {% set build_plan = [
        create_schema_ddl(source_node.schema),
        create_external_table_ddl(source_node)
      ] + refresh_external_table_ddl(source_node) 
    %}
    
    
  {% endif %}
  
  {% do return(build_plan) %}

{% endmacro %}

{% macro stage_external_sources(select=none) %}

  {% set sources_to_stage = [] %}
  
  {% for node in graph.sources.values() %}
    
    {% if node.external.location %}
      
      {% if select %}
      
        {% for src in select.split(' ') %}
        
          {% if '.' in src %}
            {% set src_s = src.split('.') %}
            {% if src_s[0] == node.source_name and src_s[1] == node.name %}
              {% do sources_to_stage.append(node) %}
            {% endif %}
          {% else %}
            {% if src == node.source_name %}
              {% do sources_to_stage.append(node) %}
            {% endif %}
          {% endif %}
          
        {% endfor %}
            
      {% else %}
      
        {% do sources_to_stage.append(node) %}
        
      {% endif %}
      
    {% endif %}
    
  {% endfor %}

  {% for node in sources_to_stage %}

    {% set loop_label = loop.index ~ ' of ' ~ loop.length %}

    {% do log(loop_label ~ ' START external source ' ~ node.schema ~ '.' ~ node.identifier, True) -%}
    
    {% set run_queue = get_external_build_plan(node) %}


    {% do log(loop_label ~ ' SKIP', True) if run_queue == [] %}
    
    {% for q in run_queue %}
    
      {% set q_msg = q|trim %}
      {% set q_log = q_msg[:50] ~ '...  ' if q_msg|length > 50 else q_msg %}
    
      {% do log(loop_label ~ ' (' ~ loop.index ~ ') ' ~ q_log, True) %}
    
      {% call statement('runner', fetch_result = True, auto_begin = False) %}
        {{ q }}
      {% endcall %}
      
      {% set status = load_result('runner')['status'] %}
      {% do log(loop_label ~ ' (' ~ loop.index ~ ') ' ~ status, True) %}
      
    {% endfor %}
    
  {% endfor %}
  
{% endmacro %}
