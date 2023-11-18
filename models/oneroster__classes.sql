with stg_sections as (
    select * from {{ ref('stg_ef3__sections')}}
    where school_year = {{ var('oneroster:active_school_year')}}
),
stg_course_offering as (
    -- avoid column ambiguity in next step
    select 
        k_course_offering,
        course_code,
        lea_id,
        local_course_title
    from {{ ref('stg_ef3__course_offerings')}} off 
    join {{ ref('stg_ef3__schools') }} sch 
        on off.k_school = sch.k_school
    where school_year = {{ var('oneroster:active_school_year')}}
),
periods as (
    select 
        k_course_section,
        listagg(distinct class_period_name, ',') as periods
    from {{ ref('stg_ef3__sections__class_periods') }} sec
    join {{ ref('stg_ef3__class_periods')}} per
        on sec.k_class_period = per.k_class_period
    where school_year = {{ var('oneroster:active_school_year')}}
    group by 1
)
select 
    {{ gen_sourced_id('class') }} as "sourcedId", 
    null::varchar as "status",
    null::date as "dateLastModified", 
    crs_offering.local_course_title as "title", -- consider adding section_id here?
    null::varchar as "grades",
    {{ gen_sourced_id('course') }} as "courseSourcedId",
    sections.local_course_code as "classCode", 
    'scheduled' as "classType", -- do we need a homeroom indicator
    sections.classroom_identification_code as "location",
    {{ gen_sourced_id('school') }} as "schoolSourcedId", 
    {{ gen_sourced_id('session') }} as "termSourcedIds",
    null::varchar as "subject",
    null::varchar as "subjectCodes",
    periods.periods as "periods",
    {{ gen_natural_key('class') }} as "metadata.edu.natural_key",
    sections.tenant_code
    -- periods
from stg_sections sections
join stg_course_offering crs_offering
    on sections.k_course_offering = crs_offering.k_course_offering
left join periods 
    on sections.k_course_section = periods.k_course_section