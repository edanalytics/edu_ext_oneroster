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
        null::string as "identifier",
        {{ gen_sourced_id('lea') }} as "parentSourcedId",
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
        null::string as "identifier",
        {{ gen_sourced_id('sea') }} as "parentSourcedId",
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
        null::string as "identifier",
        null::string as "parentSourcedId", --todo
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
