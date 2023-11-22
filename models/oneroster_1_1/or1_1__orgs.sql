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
        school_id as "identifier",
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
        lea_id as "identifier",
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
        sea_id as "identifier",
        null::string as "parentSourcedId", --todo
        {{ gen_natural_key('sea') }} as "metadata.edu.natural_key",
        tenant_code
    from seas
),

stacked as (
    select * from schools_formatted
    union all
    select * from leas_formatted
    union all 
    select * from seas_formatted
)
select * from stacked
