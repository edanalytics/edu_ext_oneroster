{% macro get_key_list(id_type) -%}
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
  {% elif id_type == 'dept' %}
    {%- set suffix = ['ed_org_id', 'department_name'] -%}

  {# users #}
  {%- elif id_type == 'student' -%}
    {% set suffix = ["'STU'", 'student_unique_id'] %}
  {% elif id_type == 'staff' %}
    {% set suffix = ["'STA'", 'staff_unique_id'] %}
  {% elif id_type == 'parent' %}
    {% set suffix = ["'PAR'", 'parent_unique_id'] -%}
  
  {# sessions #}
  {%- elif id_type == 'session' -%}
    {% set suffix = ['school_id', 
                    'session_name'] %}
  {%- elif id_type == 'school_year' -%}
    {% set suffix = ['lea_id',
                    'school_year'] -%}

  {# courses #}
  {%- elif id_type == 'course' %}
    {% set suffix = ['lea_id', 'course_code'] -%}
  

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
  {{ return(key_list) }}
{%- endmacro %}

{% macro gen_sourced_id(id_type) -%}
  {{ dbt_utils.generate_surrogate_key(get_key_list(id_type)) }}
{% endmacro %}

{% macro gen_natural_key(id_type) -%}
  {%- set fields = [] -%}
  {%- for field in get_key_list(id_type) -%}
    {%- do fields.append(
        "coalesce(cast(" ~ field ~ " as " ~ dbt.type_string() ~ "), '" ~ ""  ~"')"
    ) -%}

    {%- if not loop.last %}
        {%- do fields.append("'-'") -%}
    {%- endif -%}
  {% endfor %}
  {{ dbt.concat(fields)}}
{% endmacro %}