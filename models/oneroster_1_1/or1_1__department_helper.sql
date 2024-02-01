{{
  config(
    materialized = 'ephemeral'
    )
}}

select  
    tenant_code,
    k_course,
    ed_org_id,
    -- fill NULL values, strip commas (for CSV formatting)
    coalesce(
        replace({{ var('oneroster:course_dept_column') }}, ','), 
        'Unknown') as department_name
from {{ ref('dim_course') }}
where school_year = {{ var('oneroster:active_school_year')}}