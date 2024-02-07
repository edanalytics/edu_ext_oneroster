{{
  config(
    alias='orgs'
    )
}}
with schools as (
    select * from {{ ref('stg_ef3__schools') }}
),

leas as (
    select * from {{ ref('stg_ef3__local_education_agencies') }}
),

seas as (
    select * from {{ ref('stg_ef3__state_education_agencies') }}
),

schools_formatted as (
    select
        {{ gen_sourced_id('school') }} as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        school_name as "name",
        'school' as "type",
        school_id::string as "identifier",
        {{ gen_sourced_id('lea') }} as "parentSourcedId",
        {{ gen_natural_key('school') }} as "metadata.edu.natural_key",
        tenant_code
    from schools
),

leas_formatted as (
    select
        {{ gen_sourced_id('lea') }} as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        lea_name as "name",
        'district' as "type",
        lea_id::string as "identifier",
        {# gen_sourced_id('sea') as "parentSourcedId", #}
        null::string as "parentSourcedId", --tmp: pending update in edu_edfi_source
        {{ gen_natural_key('lea') }} as "metadata.edu.natural_key",
        tenant_code
    from leas
),

seas_formatted as (
    select
        {{ gen_sourced_id('sea') }} as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        sea_name as "name",
        'state' as "type",
        sea_id::string as "identifier",
        null::string as "parentSourcedId", --todo
        {{ gen_natural_key('sea') }} as "metadata.edu.natural_key",
        tenant_code
    from seas
),

{% if var('oneroster:use_course_departments', false) %}
  
departments_formatted as (
    select distinct
        {{ gen_sourced_id('dept') }} as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        department_name as "name",
        'department' as "type",
        department_name as "identifier",
        {{ gen_natural_key('edorg') }} as "parentSourcedId",
        {{ gen_natural_key('dept') }} as "metadata.edu.natural_key",
        tenant_code
    from {{ ref('or1_1__department_helper') }}
),
{% endif %}

stacked as (
    select * from schools_formatted
    union all
    select * from leas_formatted
    union all 
    select * from seas_formatted
    {% if var('oneroster:use_course_departments', false) %}
    union all 
    select * from departments_formatted
    {% endif %}
)
select * from stacked
