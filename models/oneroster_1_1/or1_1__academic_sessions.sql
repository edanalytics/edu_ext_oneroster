{{
  config(
    alias='academic_sessions'
    )
}}
with stg_sessions as (
    select ses.*, sch.lea_id 
    from {{ ref('stg_ef3__sessions') }} ses 
    join {{ ref('stg_ef3__schools') }} sch
        on ses.k_school = sch.k_school
    where school_year = {{ var('oneroster:active_school_year')}}
),
calendar_windows as (
    select * 
    from {{ ref('bld_ef3__school_calendar_windows') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
xwalk_session_types as (
    select * from {{ ref('xwalk_oneroster_academic_sessions_types') }}
),
summarize_school_year as (
    -- school years are designed to be global in oneroster,
    -- but do not necessarily have uniform start/end days 
    -- in the real world. 
    -- As a compromise, we define school years by district 
    -- and take the modal start/end day
    select 
        cal.tenant_code,
        lea_id,
        school_year,
        mode(first_school_day) as first_school_day,
        mode(last_school_day) as last_school_day
    from calendar_windows cal
    join {{ ref('dim_school' )}} sch 
        on cal.k_school = sch.k_school
    where k_school_calendar is null 
    group by all
),
create_school_year as (

    select 
        {{ gen_sourced_id('school_year') }} as "sourcedId",
        null::varchar as "status",
        null::date as "dateLastModified",
        concat(school_year - 1, '-', school_year) as "title",
        'schoolYear' as "type",
        first_school_day as "startDate",
        last_school_day as "endDate",
        null::varchar as "parentSourcedId",
        school_year as "schoolYear",
        {{ gen_natural_key('school_year') }} as "metadata.edu.natural_key",
        tenant_code
    from summarize_school_year
),
sessions_formatted as (
    select  
        {{ gen_sourced_id('session') }} as "sourcedId",
        null::varchar as "status",
        null::date as "dateLastModified",
        stg_sessions.academic_term as "title",
        xtype.type as "type", -- todo: hard-code to 'term'?
        stg_sessions.session_begin_date as "startDate",
        stg_sessions.session_end_date as "endDate",
        {{ gen_sourced_id('school_year') }} as "parentSourcedId",
        stg_sessions.api_year as "schoolYear",
        {{ gen_natural_key('session') }} as "metadata.edu.natural_key",
        stg_sessions.tenant_code
    from stg_sessions
    left join xwalk_session_types xtype
        on stg_sessions.academic_term = xtype.academic_term
),
stacked as (
    select * from create_school_year 
    union all
    select * from sessions_formatted

)
select * from stacked