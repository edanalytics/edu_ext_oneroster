{{
  config(
    materialized = 'ephemeral',
    )
}}

with dim_parent as (
    select * from {{ ref('dim_parent') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
student_school as (
    select * exclude tenant_code from {{ ref('fct_student_school_association') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
student_parent as (
    select * exclude tenant_code from {{ ref('fct_student_parent_association') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
dim_school as (
    select * exclude tenant_code from {{ ref('dim_school') }}
),
dim_student as (
    select * exclude tenant_code from {{ ref('dim_student') }}
),
parent_email as (
    {{ 
        edu_wh.row_pluck(ref('stg_ef3__parents__emails'),
                key='k_parent',
                column='email_type',
                preferred=var('oneroster:student_email_type', 'Home/Personal'),
                where='(do_not_publish is null or not do_not_publish)') 
    }}
),

parent_orgs as (
    select 
        dim_parent.k_parent,
        dim_school.k_lea,
        dim_school.k_school,
        dim_school.school_id,
        {{ gen_sourced_id('school') }} as sourced_id,
        student_school.is_primary_school,
        student_school.entry_date,
        dim_parent.tenant_code
    from dim_parent
    join student_parent
        on dim_parent.k_parent = student_parent.k_parent
    join student_school
        on student_school.k_student = student_parent.k_student
    join dim_school 
        on student_school.k_school = dim_school.k_school
),
parent_orgs_agg as (
    select 
        k_parent,
        listagg(distinct sourced_id, ',') as orgs
    from parent_orgs
    group by all
),

parent_students as (
    select 
        dim_parent.k_parent,
        {{ gen_sourced_id('student') }} as sourced_id,
        dim_parent.tenant_code
    from dim_parent
    join student_parent
        on dim_parent.k_parent = student_parent.k_parent
    join dim_student
        on student_parent.k_student = dim_student.k_student
),
parent_students_agg as (
    select 
        k_parent,
        listagg(distinct sourced_id, ',') as students
    from parent_students
    group by all
),

parent_keys as (
    select 
        k_parent,
        {{ gen_sourced_id('parent') }} as sourced_id,
        {{ gen_natural_key('parent') }} as natural_key
    from dim_parent
),
formatted as (
    select 
        parent_keys.sourced_id as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        true as "enabledUser", 
        parent_orgs_agg.orgs as "orgSourcedIds",
        'parent' as "role",
        parent_email.email_address as "username",
        null::string as "userIds",
        dim_parent.first_name as "givenName",
        dim_parent.last_name as "familyName",
        dim_parent.middle_name as "middleName",
        dim_parent.parent_unique_id as "identifier",
        parent_email.email_address as "email",
        null::string as "sms",
        null::string as "phone",
        parent_students_agg.students as "agentSourcedIds",
        null::string as "grades",
        null::string as "password",
        parent_keys.natural_key as "metadata.edu.natural_key",
        null::string as "metadata.edu.staff_classfication",
        null::string as "metadata.edu.primary_school",
        dim_parent.tenant_code
    from dim_parent
    join parent_keys 
        on dim_parent.k_parent = parent_keys.k_parent
    left join parent_orgs_agg
        on dim_parent.k_parent = parent_orgs_agg.k_parent
    left join parent_students_agg
        on dim_parent.k_parent = parent_students_agg.k_parent
    left join parent_email
        on dim_parent.k_parent = parent_email.k_parent
)
select * from formatted
