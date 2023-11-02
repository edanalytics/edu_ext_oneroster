with stg_staff_school_associations as (
    select * from {{ ref('stg_ef3__staff_school_associations') }}
),

stg_staff_ed_org_assign as (
    select * from {{ ref('stg_ef3__staff_education_organization_assignment_associations')}}
),

dim_staff as (
    select * from {{ ref('dim_staff') }}
),

dim_school as (
    select * from {{ ref('dim_school')}}
),

dim_student as (
    select * from {{ref('dim_student')}}
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

dim_parent as (
    select * from {{ref('dim_parent')}}
),

student_parent_associations as (
    select * from {{ ref('stg_ef3__student_parent_associations')}}
),

xwalk_relation_types as (
    select * from {{ ref('xwalk_oneroster_relation_types')}}
),

staff_users_formatted as (
    select
        ssa.k_staff as "sourcedId",
        'active' as "status",
        ssa.pull_timestamp as "dateLastModified",
        'true' as "enabledUsers",
        ssa.k_school as "orgSourceIds",
        xwalk_staff_classifications.oneroster_role as "role",
        '' as "username",
        '' as "userIds",
        staff.first_name as "givenName",
        staff.last_name as "familyName",
        staff.middle_name as "middleName",
        '' as "identifier",
        staff.email_address as "email",
        '' as "sms",
        '' as "phone",
        '' as agentSourceIds,
        '' as grades,
        '' as password
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
        ssa.k_student_xyear as "sourcedId",
        'active' as "status",
        ssa.pull_timestamp as "dateLastModified",
        'true' as "enabledUser",
        ssa.k_school as "orgSourceIds",
        'student' as "role",
        '' as "username",
        '' as "userIds",
        student.first_name as "givenName",
        student.last_name as "familyName",
        student.middle_name as "middleName",
        '' as "identifier",
        seoa.v_electronic_mails:electronicMailAddress as "email",
        '' as "sms",
        '' as "phone",
        '' as agentSourceIds,
        '' as grades,
        '' as password
    from student_school_associations ssa
    inner join dim_student student
        on ssa.k_student = student.k_student
    inner join student_ed_org_associations seoa
        on ssa.k_student = seoa.k_student
),

parent_users_formatted as (
    select
        spa.k_parent as "sourcedId",
        'active' as "status",
        spa.pull_timestamp as "dateLastModified",
        'true' as "enabledUsers",
        '' as "orgSourceIds",
        xwalk_relation_types.oneroster_role as "role",
        '' as "username",
        '' as "userIds",
        parent.first_name as "givenName",
        parent.last_name as "familyName",
        parent.middle_name as "middleName",
        '' as "identifier",
        parent.primary_email_address as "email",
        parent.mobile_phone_number as "sms",
        parent.home_phone_number as "phone",
        spa.k_student_xyear as agentSourceIds,
        '' as grades,
        '' as password
    from student_parent_associations spa
    inner join dim_parent parent
        on parent.k_parent = spa.k_parent
    left join xwalk_relation_types
        on xwalk_relation_types.relation_type = spa.relation_type
),

stacked as (
    select * from staff_users_formatted
    union
    select * from student_users_formatted
    union
    select * from parent_users_formatted
)

select * from stacked
