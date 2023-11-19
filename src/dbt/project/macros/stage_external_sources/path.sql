{% macro year_month_day_path(key, value) %}
  {# we assume the date follow the 'YYYY-MM-DD' format #}
  {% set path = 'year=' ~ value[:4] ~ '/month=' ~ value[5:7] ~ '/day=' ~ value[8:] %}
  {{return(path)}}
{% endmacro %}

{% macro date_path(key, value) %}
  {# we assume the date follow the 'YYYY-MM-DD' format #}
  {% set path = value[:4] ~ value[5:7] ~ value[8:] %}
  {{return(path)}}
{% endmacro %}

{% macro date_path_dash(key, value) %}
  {# we assume the date follow the 'YYYY-MM-DD' format #}
  {% set path = value[:4] ~ '-' ~ value[5:7] ~ '-' ~ value[8:] %}
  {{return(path)}}
{% endmacro %}

{% macro loaded_at_date_path_dash(key, value) %}
  {# we assume the date follow the 'YYYY-MM-DD' format #}
  {% set path = 'loaded_at=' ~ value[:4] ~ '-' ~ value[5:7] ~ '-' ~ value[8:] %}
  {{return(path)}} 
{% endmacro %}

{% macro custom_string_path(key, value) %}
  {# 'key' (prefix paths) comes from 'path_macro_key' of render_from_context() in refresh_external_table.sql #}
  {% set path = key ~ value %}
  {{return(path)}}
{% endmacro %}