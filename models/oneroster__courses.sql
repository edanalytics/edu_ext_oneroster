with stg_courses as (
    select * from {{ ref('stg_ef3__courses')}}
    where school_year = {{ var('oneroster:active_school_year')}}
)
select 
    {{ gen_sourced_id('course') }} as "sourcedId",--need to add edorg here?
    null::string as "status",
    null::date as "dateLastModified", 
    {{ gen_sourced_id('school_year') }} as "schoolYearSourcedId", -- need school_id here
    course_title as "title", 
    course_code  as "courseCode", 
    null::string as "grades",
    {{ gen_sourced_id('edorg') }} as "orgSourcedId",
    -- required to be SCED codes, not generally available
    null::string as "subjects",
    null::string as "subjectCodes",
    tenant_code
from stg_courses crs

