{{
  config(
    alias='users'
    )
}}
select * from {{ ref('or1_1__int_users_student') }}
union all 
select * from {{ ref('or1_1__int_users_staff') }}
{% if var('oneroster:include_parents', False) %}
  union all
  select * from {{ ref('or1_1__int_users_parents') }}
{% endif %}