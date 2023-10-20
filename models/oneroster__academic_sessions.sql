with stg_sessions as (
    select * from {{ ref('stg_ef3__sessions') }}
    where not is_deleted
),

stg_grading_periods as (
    select * from {{ ref('stg_ef3__grading_periods')}}
    where not is_deleted
),

stg_sessions_grading_periods as (
    select * from {{ ref('stg_ef3__sessions__grading_periods')}}
),

xwalk_session_types as (
    select * from {{ ref('xwalk_oneroster_academic_sessions_types') }}
),

sessions_formatted as (
    select
        s.k_session as "sourcedId",
        'active' as "status",
        s.pull_timestamp as "dateLastModified",
        s.session_name as "title",
        xtype.type as "type",
        s.session_begin_date as "startDate",
        s.session_end_date as "endDate",
        {{ dbt_utils.surrogate_key(['tenant_code', 'api_year']) }} as "parentSourcedId",
        s.api_year as "schoolYear"
    from stg_sessions s
    inner join xwalk_session_types xtype
        on s.academic_term = xtype.academic_term
),

grading_periods_formatted as (
    select
        gp.k_grading_period as "sourcedId",
        'active' as "status",
        gp.pull_timestamp as "dateLastModified",
        gp.grading_period as "title",
        'gradingPeriod' as "type",
        gp.begin_date as "startDate",
        gp.end_date as "endDate",
        sgp.k_session as "parentSourcedId",
        gp.api_year as "schoolYear"
    from stg_grading_periods gp
    inner join stg_sessions_grading_periods sgp
        on gp.k_grading_period = sgp.k_grading_period
),

stacked as (
    select * from sessions_formatted
    union
    select * from grading_periods_formatted
)

select * from stacked