{{
  config(
    materialized = 'ephemeral',
    )
}}

with dim_student as (
    select * from {{ ref('dim_student') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
student_school as (
    select * from {{ ref('fct_student_school_association') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
dim_school as (
    select * from {{ ref('dim_school') }}
),
grade_level_xwalk as (
    select * from {{ ref('xwalk_oneroster_grade_levels') }}
), --todo look at active enroll
user_ids as (
    select 
        k_student,
        k_lea,
        listagg(concat('{', id_system, ':', id_code, '}'), ',') as ids
    from {{ ref('stg_ef3__stu_ed_org__identification_codes') }}
    where api_year = {{ var('oneroster:active_school_year')}}
    group by all
),
student_email as (
    {{ 
        edu_wh.row_pluck(ref('stg_ef3__stu_ed_org__emails'),
                key='k_student',
                column='email_type',
                preferred=var('oneroster:student_email_type', 'Home/Personal'),
                where='(do_not_publish is null or not do_not_publish)') 
    }}
),

student_orgs as (
    select 
        k_student,
        dim_school.k_lea,
        dim_school.k_school,
        dim_school.school_id,
        student_school.tenant_code
    from student_school
    join dim_school 
        on student_school.k_school = dim_school.k_school
),
student_orgs_agg as (
    select 
        k_student,
        k_lea,
        listagg({{ gen_sourced_id('school') }}, ',') as orgs
    from student_orgs
    group by all
),
student_keys as (
    select 
        k_student,
        {{ gen_sourced_id('student') }} as sourced_id,
        {{ gen_natural_key('student') }} as natural_key
    from dim_student
),
formatted as (
    select 
        student_keys.sourced_id as "sourcedId",
        null::string as "status",
        null::date as "dateLastModified",
        true as "enabledUser", 
        student_orgs_agg.orgs as "orgSourcedIds",
        'student' as "role",
        null::varchar as "username",
        user_ids.ids as "userIds",
        dim_student.first_name as "givenName",
        dim_student.last_name as "familyName",
        dim_student.middle_name as "middleName",
        dim_student.student_unique_id as "identifier",
        student_email.email_address as "email",
        null::string as "sms",
        null::string as "phone",
        null::string as "agentSourceIds",
        grade_level_xwalk.oneroster_grade_level as "grades",
        null::string as "password",
        student_keys.natural_key as "metadata.edu.natural_key",
        null::string as "metadata.edu.staff_classfication",
        dim_student.tenant_code
    from dim_student
    join student_keys 
        on dim_student.k_student = student_keys.k_student
    -- note that this join expands the grain by district in certain cases
    join student_orgs_agg
        on dim_student.k_student = student_orgs_agg.k_student
    join user_ids
        on dim_student.k_student = user_ids.k_student
        and student_orgs_agg.k_lea = user_ids.k_lea
    left join student_email 
        on dim_student.k_student = student_email.k_student 
        and student_orgs_agg.k_lea = student_email.k_lea
    left join grade_level_xwalk 
        on dim_student.grade_level = grade_level_xwalk.edfi_grade_level
)
select * from formatted