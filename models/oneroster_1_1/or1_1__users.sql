-- SPDX-FileCopyrightText: 2022 Education Analytics
-- SPDX-License-Identifier: MPL-2.0

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
  select * from {{ ref('or1_1__int_users_parent') }}
{% endif %}