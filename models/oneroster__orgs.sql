with schools as (
    select * from {{ ref('stg_ef3__schools') }}
),

leas as (
    select * from {{ ref('stg_ef3__local_education_agencies') }}
),

schools_formatted as (
    select
        k_school as sourcedId,
        'active' as status,
        pull_timestamp as dateLastModified,
        school_name as name,
        'school' as type,
        '' as identifier,
        k_lea as parentSourceId
    from schools
),

leas_formatted as (
    select
        k_lea as sourcedId,
        'active' as status,
        pull_timestamp as dateLastModified,
        lea_name as name,
        'district' as type, --Always a district?
        '' as identifier,
        k_lea__parent as parentSourceId
    from leas
),

stacked as (
    select * from schools_formatted
    union
    select * from leas_formatted
)

select * from stacked
