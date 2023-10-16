with stg_staff_school_associations as (
    select * from {{ ref('stg_ef3__staff_school_associations') }}
),

stg_staff_ed_org_assign as (
    select * from {{ ref('stg_ef3__staff_education_organization_assignment_associations')}}
),

dim_staff as (
    select * from {{ ref('dim_staff') }}
),

xwalk_staff_classifications as (
    select * from {{ ref('xwalk_oneroster_staff_classifications')}}
),

student_ed_org_associations as (
    select * from {{ ref('stg_ef3__student_education_organization_associations')}}
),

student_school_associations as (
    select * from {{ ref('stg_ef3__student_school_associations')}}
),

xwalk_staff_classifications as (
    select * from {{ ref('xwalk_oneroster_staff_classifications')}}
),

staff_users_formatted as (
    select
        ssa.k_staff as sourcedId, -- TODO generate a new key to match length?
        'active' as status,
        ssa.pull_timestamp as dateLastModified,
        'true' as enabledUsers,
        ssa.k_school as orgSourceIds,
        'teacher' as role,
        '' as username,
        '' as userIds,
        staff.first_name as givenName,
        staff.last_name as familyName,
        staff.middle_name as middleName,
        '' as identifier,
        staff.email_address as email,
        '' as sms,
    xwalk_staff_classifications.oneroster_role as role,
    from stg_staff_school_associations ssa
    inner join dim_school
        on dim_school.k_school = ssa.k_school
    inner join dim_staff staff
        on ssa.k_staff = staff.k_staff
    left join stg_staff_ed_org_assign as lea_assign
        on ssa.k_staff = lea_assign.k_staff
        and ssa.school_year = lea_assign.school_year
        and dim_school.k_lea = lea_assign.k_lea
        and lea_assign.ed_org_type = 'LocalEducationAgency'
    left join stg_staff_ed_org_assign as school_assign
        on ssa.k_staff = school_assign.k_staff
        and ssa.api_year = school_assign.school_year
        and dim_school.k_school = school_assign.k_school
        and school_assign.ed_org_type = 'School'
    left join xwalk_staff_classifications
        on xwalk_staff_classifications.staff_classification = coalesce(school_assign.staff_classification, lea_assign.staff_classification)
),

student_users_formatted as (
    select
        ssa.k_student_xyear as sourcedId, -- TODO generate a new key to match length?
        'active' as status,
        ssa.pull_timestamp as dateLastModified,
        'true' as enabledUser,
        ssa.k_school as orgSourceIds,
        'student' as role,
        '' as username,
        '' as userIds,
        student.first_name as givenName,
        student.last_name as  familyName,
        student.middle_name as  middleName,
        '' as identifier,
        seoa.v_electronic_mails:electronicMailAddress as email,
        '' as sms,
        '' as phone
    from student_school_associations ssa
    inner join dim_student student
        on ssa.k_student = student.k_student
    inner join student_ed_org_associations seoa
        on ssa.k_student = seoa.k_student
),

stacked as (
    select * from staff_users_formatted
    union
    select * from student_users_formatted
)

select * from stacked