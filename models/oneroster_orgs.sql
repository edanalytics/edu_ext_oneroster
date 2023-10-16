with schools as (
    select * from {{ ref('stg_ef3__schools') }}
),

leas as (
    select * from {{ ref('stg_ef3__local_education_agencies') }}
),

schools_formatted as (
    select
        k_school as sourceId,
        'active' as status,
        pull_timestamp as dateLastModified,
        school_name as name,
        'school' as type,
        '' as identifier,
        '' as parentSourceId
    from schools
),

leas_formatted as (
    select
        k_lea as sourceId,
        'active' as status,
        pull_timestamp as dateLastModified,
        lea_name as name,
        'district' as type, --Always a district?
        '' as identifier,
        '' as parentSourceId
    from leas
),

stacked as (
    select * from schools_formatted
    union
    select * from leas_formatted
)

select * from stacked
