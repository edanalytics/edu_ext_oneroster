{{
  config(
    materialized = 'ephemeral',
    )
}}
with dim_staff as (
    select * from {{ ref('dim_staff') }}
),
dim_school as (
    select * from {{ ref('dim_school') }}
),
staff_school as (
    select * from {{ ref('fct_staff_school_association') }}
    -- only consider configured active school year
    where school_year = {{ var('oneroster:active_school_year')}}
),
role_xwalk as (
    select * from {{ ref('xwalk_oneroster_staff_classifications') }}
),
staff_role as (
    select 
        k_staff,
        oneroster_role,
        staff_school.staff_classification
    from staff_school
    join role_xwalk
        on staff_school.staff_classification = role_xwalk.staff_classification
    -- only one role per staff. if multiple, prefer admin over teacher
    qualify 1 = row_number() over(partition by k_staff order by oneroster_role)
),

user_ids as (
    select 
        k_staff,
        listagg(concat('{', id_system, ':', id_code, '}'), ',') as ids
    from {{ ref('stg_ef3__staffs__identification_codes') }}
    where api_year = {{ var('oneroster:active_school_year')}}
    group by all
),

-- splitting this into two models to support customizable org guids
staff_orgs as (
    select 
        k_staff,
        staff_school.tenant_code,
        dim_school.k_school,
        dim_school.school_id
    from staff_school 
    join dim_school
        on staff_school.k_school = dim_school.k_school
),
staff_orgs_agg as (
    select 
        k_staff,
        listagg({{ gen_sourced_id('school') }}, ',') as orgs
    from staff_orgs
    group by all
),

formatted as (
    select 
        {{ gen_sourced_id('staff') }} as "sourcedId", 
        null::string as "status",
        null::date as "dateLastModified",
        true as "enabledUser",
        staff_orgs_agg.orgs as "orgSourceIds",
        staff_role.oneroster_role as "role",
        dim_staff.email_address as "username",
        user_ids.ids as "userIds",
        dim_staff.first_name as "givenName",
        dim_staff.last_name as "familyName",
        dim_staff.middle_name as "middleName",
        dim_staff.staff_unique_id as "identifier",
        dim_staff.email_address as "email",
        null::string as "sms",
        null::string as "phone",
        null::string as "agentSourceIds",
        null:string as "grades",
        null::string as "password",
        {{ gen_natural_key('staff') }} as "metadata.edu.natural_key",
        staff_role.staff_classification as "metadata.edu.staff_classification",
        dim_staff.tenant_code
    from dim_staff
    join user_ids 
        on dim_staff.k_staff = user_ids.k_staff
    join staff_role
        on dim_staff.k_staff = staff_role.k_staff
    join staff_orgs_agg 
        on dim_staff.k_staff = staff_orgs_agg.k_staff
)
select * from formatted