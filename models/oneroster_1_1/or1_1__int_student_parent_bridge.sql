{#
    This "bridge" table is used by both int_users_parent and int_users_student
    to link students and parents (via the OneRoster agentSourcedIds).
#}
{{
  config(
    materialized = 'ephemeral'
    )
}}

with dim_parent as (
    select * exclude tenant_code from {{ ref('dim_parent') }}
    where school_year = {{ var('oneroster:active_school_year')}}
),
dim_student as (
    select * exclude tenant_code from {{ ref('dim_student') }}
),
student_parent as (
    select * from {{ ref('fct_student_parent_association') }}
    where school_year = {{ var('oneroster:active_school_year')}}
)
select 
    student_parent.k_student,
    {{ gen_sourced_id('student') }} as student_sourced_id,
    student_parent.k_parent,
    {{ gen_sourced_id('parent') }} as parent_sourced_id
from dim_student
    join student_parent
        on student_parent.k_student = dim_student.k_student
    join dim_parent
        on dim_parent.k_parent = student_parent.k_parent