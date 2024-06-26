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
    select * exclude tenant_code from {{ ref('dim_school') }}
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
        {{ gen_sourced_id('school') }} as sourced_id,
        student_school.is_primary_school,
        student_school.entry_date,
        student_school.tenant_code
    from student_school
    join dim_school 
        on student_school.k_school = dim_school.k_school
),
student_orgs_agg as (
    select 
        k_student,
        listagg(distinct sourced_id, ',') as orgs,
        -- create columns for primary school extension
        max_by(sourced_id, is_primary_school, 1)[0]::string as primary_school_sourced_id,
        max_by(sourced_id, entry_date, 1)[0]::string as latest_school_sourced_id
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
        student_email.email_address as "username",
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
        coalesce(student_orgs_agg.primary_school_sourced_id, student_orgs_agg.latest_school_sourced_id) as "metadata.edu.primary_school",
        dim_student.tenant_code
    from dim_student
    join student_keys 
        on dim_student.k_student = student_keys.k_student
    left join student_orgs_agg
        on dim_student.k_student = student_orgs_agg.k_student
    left join user_ids
        on dim_student.k_student = user_ids.k_student
    left join student_email
        on dim_student.k_student = student_email.k_student
    left join grade_level_xwalk 
        on dim_student.grade_level = grade_level_xwalk.edfi_grade_level
)
select * from formatted
