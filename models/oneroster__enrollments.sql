with stg_staff_section_associations as (
    select * from {{ ref('stg_ef3__staff_section_associations') }}
    where not is_deleted
        and (end_date >= current_date
            or end_date is not null)
),

stg_student_section_associations as (
    select * from {{ ref('stg_ef3__student_section_associations')}}
    where not is_deleted
        and (end_date >= current_date
            or end_date is not null)
),

stg_sections as (
    select * from {{ ref('stg_ef3__sections')}}
    where not is_deleted
),

xwalk_classroom_positions as (
    select * from {{ ref('xwalk_oneroster_classroom_positions')}}
),

staff_enrollments_formatted as (
    select
        concat(ssa.k_staff, ssa.k_course_section) as sourcedId, -- TODO generate a new key to match length?
        'active' as status,
        ssa.pull_timestamp as dateLastModified,
        {# null as metadata, -- TODO exclude? #}
        ssa.k_staff as user,
        ssa.k_course_section as class,
        sec.k_school as school,
        'teacher' as role,
        xwalk.is_primary as primary,
        begin_date as beginDate,
        end_date as endDate
    from stg_staff_section_associations ssa
    inner join stg_sections sec
        on ssa.k_course_section = sec.k_course_section
    inner join xwalk_classroom_positions xwalk
        on ssa.classroom_position = xwalk.classroom_position
),

student_enrollments_formatted as (
    select
        concat(ssa.k_student_xyear, ssa.k_course_section) as sourcedId, -- TODO generate a new key to match length?
        'active' as status,
        ssa.pull_timestamp as dateLastModified,
        {# null as metadata, -- TODO exclude? #}
        ssa.k_student_xyear as user,
        ssa.k_course_section as class,
        sec.k_school as school,
        'student' as role,
        false as primary,
        begin_date as beginDate,
        end_date as endDate
    from stg_student_section_associations ssa
    inner join stg_sections sec
        on ssa.k_course_section = sec.k_course_section
),

stacked as (
    select * from staff_enrollments_formatted
    union
    select * from student_enrollments_formatted
)

select * from staff_enrollments_formatted