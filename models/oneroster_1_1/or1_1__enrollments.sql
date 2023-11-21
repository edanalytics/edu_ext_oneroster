{{
  config(
    alias='enrollments'
    )
}}
with stg_staff_section_associations as (
    select * from {{ ref('stg_ef3__staff_section_associations') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),

stg_student_section_associations as (
    select * from {{ ref('stg_ef3__student_section_associations')}}
    where school_year = {{ var('oneroster:active_school_year')}}
),

stg_sections as (
    select * from {{ ref('stg_ef3__sections')}}
),

xwalk_classroom_positions as (
    select * from {{ ref('xwalk_oneroster_classroom_positions')}}
),

staff_enrollments_formatted as (
    select
        {{ gen_sourced_id('staff_enr') }} as "sourcedId",
        null::varchar as "status",
        null::date as "dateLastModified",
        {{ gen_sourced_id('class') }} as "classSourcedId",
        {{ gen_sourced_id('school') }} as "schoolSourcedId",
        {{ gen_sourced_id('staff') }} as "userSourcedId",
        'teacher' as "role",
        xwalk.is_primary::boolean as "primary",
        begin_date as "beginDate",
        end_date as "endDate",
        {{ gen_natural_key('staff_enr') }} as "metadata.edu.natural_key",
        ssa.tenant_code
    from stg_staff_section_associations ssa
    left join xwalk_classroom_positions xwalk
        on ssa.classroom_position = xwalk.classroom_position
),

student_enrollments_formatted as (
    select
        {{ gen_sourced_id('stu_enr') }} as "sourcedId",
        null::varchar as "status",
        null::date as "dateLastModified",
        {{ gen_sourced_id('class') }} as "classSourcedId",
        {{ gen_sourced_id('school') }} as "schoolSourcedId",
        {{ gen_sourced_id('student') }} as "userSourcedId",
        'student' as "role",
        false as "primary",
        begin_date as "beginDate",
        end_date as "endDate",
        {{ gen_natural_key('stu_enr') }} as "metadata.edu.natural_key",
        ssa.tenant_code
    from stg_student_section_associations ssa
)
select * from staff_enrollments_formatted
union all
select * from student_enrollments_formatted
