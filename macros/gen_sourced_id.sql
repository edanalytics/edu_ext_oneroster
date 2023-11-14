{% macro gen_sourced_id(id_type) -%}
  {% set prefix = var('oneroster:id_prefix', 'tenant_code') %}
    
  {# orgs #}
  {%- if id_type   == 'sea' %}
    {% set suffix = 'sea_id' %}
  {% elif id_type == 'lea' %}
    {% set suffix = 'lea_id' %}
  {% elif id_type == 'school' %}
    {% set suffix = 'school_id' %}
  {% elif id_type == 'edorg' %}
    {%- set suffix = 'ed_org_id' -%}

  {# users #}
  {%- elif id_type == 'student' -%}
    {% set suffix = 'student_unique_id' %}
  {% elif id_type == 'staff' %}
    {% set suffix = 'staff_unique_id' %}
  {% elif id_type == 'parent' %}
    {% set suffix = 'parent_unique_id' -%}
  
  {# sessions #}
  {%- elif id_type == 'session' -%}
    {% set suffix = ['school_id', 
                    'session_name'] %}
  {%- elif id_type == 'school_year' -%}
    {% set suffix = ['lea_id',
                    'school_year'] -%}

  {# courses #}
  {%- elif id_type == 'course' %}
    {% set suffix = 'course_code' -%}
  

  {# classes #}
  {%- elif id_type == 'class' %}
    {% set suffix = ['lower(local_course_code)',
                    'school_id',
                    'lower(section_id)',
                    'lower(session_name)'] -%}

  {# enrollments #}
  {%- elif id_type == 'stu_enr' -%}
    {% set suffix = [
                    'student_unique_id',
                    'lower(local_course_code)',
                    'school_id',
                    'lower(section_id)',
                    'lower(session_name)',
                    'begin_date'] -%}

  {%- elif id_type == 'staff_enr' -%}
    {% set suffix = [
                    'staff_unique_id',
                    'lower(local_course_code)',
                    'school_id',
                    'lower(section_id)',
                    'lower(session_name)',
                    'begin_date'] %}

  {%- endif -%}

  {# listify prefix #}
  {%- if prefix is not iterable or prefix is string -%}
    {% set prefix = [prefix] %}
  {%- endif -%}
  {# listify suffix #}
  {%- if suffix is not iterable or suffix is string -%}
    {% set suffix = [suffix] %}
  {%- endif -%}

  {%- set key_list = prefix + suffix -%}
  {{ dbt_utils.surrogate_key(key_list) }}
{%- endmacro %}