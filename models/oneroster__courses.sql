with stg_courses as (
    select * from {{ ref('stg_ef3__courses')}}
)
select 
    crs.k_course as sourcedId, 
    'active' as status,
    crs.pull_timestamp as dateLastModified, 
    crs.school_year as schoolYearSourceId,
    crs.course_title as title, 
    crs.course_code  as courseCode, 
    -- v_offered_grade_levels as grades [currently an array need to flatten out] -- also not required field
    concat(crs.tenant_code, crs.ed_org_id) as orgSourcedId
    -- subjects   
    -- subjectCodes
from stg_courses crs
