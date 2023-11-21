{{
  config(
    alias='courses'
    )
}}
with stg_courses as (
    select * from {{ ref('stg_ef3__courses')}}
    where school_year = {{ var('oneroster:active_school_year')}}
),
-- want courses defined by district, so grab this from offerings and reduce down
course_leas as (
    select distinct k_course, lea_id 
    from {{ ref('stg_ef3__course_offerings')}} as co 
    join {{ ref('stg_ef3__schools') }} as s 
        on co.k_school = s.k_school
    where school_year = {{ var('oneroster:active_school_year')}}
)
select 
    {{ gen_sourced_id('course') }} as "sourcedId",
    null::string as "status",
    null::date as "dateLastModified", 
    {{ gen_sourced_id('school_year') }} as "schoolYearSourcedId", 
    course_title as "title", 
    course_code  as "courseCode", 
    null::string as "grades",
    {{ gen_sourced_id('edorg') }} as "orgSourcedId",
    -- required to be SCED codes, not generally available
    null::string as "subjects",
    null::string as "subjectCodes",
    {{ gen_natural_key('course') }} as "metadata.edu.natural_key",
    tenant_code
from stg_courses crs
join course_leas 
    on crs.k_course = course_leas.k_course

