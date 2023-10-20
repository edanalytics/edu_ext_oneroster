with stg_courses as (
    select * from {{ ref('stg_ef3__courses')}}
),
stg_course_offering as (
    select * from {{ ref('stg_ef3__course_offerings')}}
)
select 
    crs.k_course as "sourcedId", 
    'active' as "status",
    crs.pull_timestamp as "dateLastModified", 
    crs.course_title as "title", 
    crs.course_code  as "courseCode", 
    -- v_offered_grade_levels as grades [currently an array need to flatten out] -- also not required field
    crs_offering.k_school as "orgSourcedId"
    -- subjects   
    -- subjectCodes
from stg_courses crs
join stg_course_offering crs_offering on crs.k_course = crs_offering.k_course

