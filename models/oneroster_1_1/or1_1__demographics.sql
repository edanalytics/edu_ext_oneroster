{{
  config(
    alias='demographics'
    )
}}
with dim_student as (
    select * from {{ ref('dim_student')}}
    where school_year = {{ var('oneroster:active_school_year') }}
),
stg_students as (
    select * from {{ ref('stg_ef3__students') }}
),
stu_races as (
    select * from {{ ref('stg_ef3__stu_ed_org__races') }}
    where school_year = {{ var('oneroster:active_school_year') }}
),
race_pivot as (
    select 
        k_student,
        {{ edu_wh.alias_pivot(
            column='race',
            cmp_col_name='edfi_race_code',
            alias_col_name='oneroster_race_code',
            xwalk_ref='xwalk_oneroster_races',
            cast='boolean',
            null_false=True,
            quote_identifiers=True
          )
        }}
    from stu_races
    group by all
),
student_keys as (
    select 
        k_student,
        {{ gen_sourced_id('student') }} as sourced_id,
        {{ gen_natural_key('student') }} as natural_key
    from dim_student
),
formatted as (
    select 
        student_keys.sourced_id as "sourcedId",
        null::string as "status",
        null::string as "dateLastModified",
        dim_student.birth_date as "birthDate",
        xwalk_oneroster_gender.oneroster_sex_code as "sex",
        race_pivot."americanIndianOrAlaskaNative"::string as "americanIndianOrAlaskaNative",
        race_pivot."asian"::string as "asian",
        race_pivot."blackOrAfricanAmerican"::string as "blackOrAfricanAmerican",
        race_pivot."nativeHawaiianOrOtherPacificIslander"::string as "nativeHawaiianOrOtherPacificIslander",
        race_pivot."white"::string as "white",
        (array_size(dim_student.race_array) > 1)::string as "demographicRaceTwoOrMoreRaces",
        dim_student.has_hispanic_latino_ethnicity::string as "hispanicOrLatinoEthnicity",
        stg_students.birth_country as "countryOfBirthCode",
        stg_students.birth_state as "stateOfBirthAbbreviation",
        stg_students.birth_city as "cityOfBirth",
        null::string as "publicSchoolResidenceStatus",
        student_keys.natural_key as "metadata.edu.natural_key",
        {% for key, value in var('oneroster:demographic_extensions', {}).items() %}
        dim_student.{{ key }}::string as "metadata.{{ value }}",
        {% endfor %}
        dim_student.tenant_code
    from dim_student 
    join student_keys 
        on dim_student.k_student = student_keys.k_student
    join stg_students
        on dim_student.k_student = stg_students.k_student
    left join race_pivot
        on dim_student.k_student = race_pivot.k_student
    left join {{ ref('xwalk_oneroster_gender') }}
        on dim_student.gender = xwalk_oneroster_gender.edfi_gender_code

)
select * from formatted
