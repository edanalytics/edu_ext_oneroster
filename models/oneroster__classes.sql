with stg_sections as (
    select * from {{ ref('stg_ef3__sections')}}
),
stg_course_offering as (
    select * from {{ ref('stg_ef3__course_offerings')}}
)
select 
    sections.k_course_section as sourcedId, 
    'active' as status,
    sections.pull_timestamp as dateLastModified, 
    crs_offering.local_course_title as title, 
    -- grades in v_offered_grade_levels array : also not a required field
    crs_offering.k_course           as courseSourceId,
    crs_offering.local_course_code  as classCode, 
    -- not sure if this is the right approach, should we xwalk this?
    -- (ie a join between local_course_code in edfi and xwalk, maybe just a list of homerooms?)
    case 
        when crs_offering.local_course_title ilike 'homeroom%' then 'homeroom'
        else 'scheduled' end as classType, 
    -- location
    sections.k_school as schoolSourceId, 
    crs_offering.k_session as termSourceId
    -- subjects
    -- subjectCodes
    -- periods
from stg_sections sections
join stg_course_offering crs_offering
    on sections.k_course_offering = crs_offering.k_course_offering