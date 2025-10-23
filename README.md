# edu_ext_oneroster
OneRoster CSV standard in the EDU framework

## License
This package is free to use for noncommercial purposes. 
See [License](LICENSE.md).

## Implementation notes
- SourcedIds are MD5 hashes of an underlying natural key defined in [gen_sourced_id](macros/gen_sourced_id.sql).
- User SourcedIds are forced to contain a prefix distinguishing between role. 
  This is to force separation: not all source systems guarantee uniqueness between
  staff, student, and parent IDs. These IDs are then prefixed with 'STA', 'STU',
  and 'PAR' respectively.
- The SchoolYear academicSession is defined once per district using the modal begin
  and end dates. 
- Remaining academicSessions are taken more or less as-is from the Ed-Fi Sessions object.
- This package is defined to only support one school year at a time. Which school year
  is supported is configurable through a variable, to avoid prematurely rotating
  to the next school year as soon as the ODS is created if the current school year
  is not yet concluded.
- A feature to allow multiple school years to be created at once may be added if 
  demand arises.
- The tables include a `tenant_code` column to support row-level security in the warehouse,
  but this is not part of the OneRoster standard and should be excluded from extracts.
- Unlike the rest of edu, columns in the OneRoster tables are specified case-sensitively
  to match the OneRoster standard. Column names must therefore be double-quoted 
  in SQL statements.
- The tables are named with the `or1_1` prefix to support namespacing for future
  versions of the OneRoster standard, but are aliased to simpler names within the
  database. The tables are _not_ specified with case-sensitivity, but files
  created from them should be.

## Unique Keys
OneRoster uses the term `SourcedId` to refer to the unique key of all files in the OneRoster standard. This implementation uses the following methodology and principles:
- All unique keys are the MD5 hash of a concatenation of Natural key values, separated by hyphens (`-`).
- For clarity/transparency, the literal string value that is hashed is included in the file as an extension column called `metadata.edu.natural_key`
- By default, all natural keys are prefixed with `tenant_code`, which is a human-readable string identifying a district. This can be overridden to be a constant string if desired using the variable `oneroster:id_prefix`
- Any natural key component that is non-integer is cast to lower-case for consistency

The natural keys for each resource are defined in the macro [gen_sourced_id](macros/gen_sourced_id.sql), but are written out below for clarity.

### Org
- tenant_code (or constant string, if configured)
- ed_org_id (`sea_id`, `lea_id`, or `school_id`, for the respective org-types)

### Users
- tenant_code (or constant string, if configured)
- The literal string `STU`, `STA`, or `PAR`, for students, staff, or parents
- `student_unique_id`, `staff_unique_id`, or `parent_unique_id`, respectively
  - Note that this is the unique person identifier configured in Ed-Fi, and exactly which type of ID this is can vary across implementations.

### Sessions
For terms/semesters/etc, this is a school-specific session definition, taken
from Ed-Fi's definition of Sessions.
- tenant_code (or constant string, if configured)
- school_id
- session_name

For school years, each district has its own definition:
- tenant_code (or constant string, if configured)
- lea_id
- school_year (4 digit number representing the Spring year, e.g. for 2023-2024, `2024`)

### Courses
- tenant_code (or constant string, if configured)
- lea_id
- course_code

### Classes
- tenant_code (or constant string, if configured)
- school_id
- lower(section_id)
- lower(session_name)

Section ID and Session Name are cast to lower case to ensure consistency.
Session is included in the Class definition to align with how Ed-Fi thinks about
Sections, as well as because Ed-Fi Sessions are not date-exclusive and using dates
alone may not uniquely identify the session in which a Section is offered.

### Enrollments
Student Enrollments are a `student_unique_id`, the `local_course_code` from Ed-Fi's `CourseOffering`, the unique key of a Class, plus the `begin_date`. Note that students may enter and exit the same Class multiple times,
requiring the presence of `begin_date` in the enrollment record.
- tenant_code (or constant string, if configured)
- student_unique_id
- lower(local_course_code)
- school_id
- lower(section_id)
- lower(session_name)
- begin_date

Staff enrollments are the same, but substituting staff_unique_id
- tenant_code (or constant string, if configured)
- staff_unique_id
- lower(local_course_code)
- school_id
- lower(section_id)
- lower(session_name)
- begin_date



## Required Seed Files
Templates for required seed files are located in the [seed_templates](seed_templates/)

1. Academic Sessions Types Mapping
- File name: `xwalk_oneroster_academic_sessions_types.csv`
- Columns:
  - `session_name`: Comes from the Ed-Fi Sessions resource, Session Name field.
  - `type`: Must be one of the [OneRoster sessionType](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452027) list of values (gradingPeriod, semester, schoolYear, term).
 
2. Classroom Positions Primary Teacher Mapping
- File name: `xwalk_oneroster_classroom_positions.csv`
- Columns:
  - `classroom_position`: Comes from the Ed-Fi Staff Section Associations resource, Classroom Position field.
  - `is_primary`: TRUE if this is the primary teacher role, FALSE otherwise. FALSE for students.

3. Grade Level Mapping
- File name: `xwalk_oneroster_grade_levels.csv`
- Columns: 
  - `edfi_grade_level`: Grade level descriptors in the source Ed-Fi system
  - `oneroster_grade_level` Codes from the [CEDS Entry Grade Level definition](https://ceds.ed.gov/CEDSElementDetails.aspx?TermId=7100)

4. Staff Classification Mapping
- File name: `xwalk_oneroster_staff_classifications.csv`
- Columns:
  - `staff_classification`: Comes from the Ed-Fi Staff Ed Org Assignment Associations resource, Staff Classification field.
  - `oneroster_role`: Must be one of the [OneRoster RoleType](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452025) list of values (administrator, aide, guardian, parent, proctor, relative, student, teacher).

5. Race Mapping
- File name: `xwalk_oneroster_races.csv`
- Columns: 
  - `edfi_race_code`: Values in the Ed-Fi RaceDescriptor
  - `oneroster_race_code`: Must be one of the [Oneroster Race](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452012) values (americanIndianOrAlaskaNative, asian, blackOrAfricanAmerican, nativeHawaiianOrOtherPacificIslander, white).

6. Gender Mapping 
- File name: `xwalk_oneroster_gender.csv`
- Columns: 
  - `edfi_gender_code`: Values in the Ed-Fi SexDescriptor.
  - `oneroster_sex_code`: Must be one of the [Oneroster Gender](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452020) list of values (male, female).


## Configuration variables
`oneroster:id_prefix`: A prefix to be included in all sourcedIds. By default this is just `tenant_code`, but this can be overridden if a single unique string value is desired for all tenants.

`oneroster:active_school_year`: The school-year on which to build OneRoster files. This should be rotated at year-rollover time, when incoming data from the school year that's about to begin has settled enough to support rostering.

`oneroster:student_email_type`: The email_type that will be preferred for student users. 

`oneroster:demographic_extensions`: Extensions to add to the demographic table. These are
key-value pairs composed of a column name from `dim_student` and the desired column name in 
the demographics file, respectively. Note: only columns in `dim_student` can be added here at the moment.

Column names will always begin with `metadata.`, and the specified value will be appended to the end. To follow the typical standard, include `edu.` in the name, but extensions are not forced to use the `edu` namespace. 
Example:
```
'oneroster:demographic_extensions':
  is_special_education_annual: 'edu.special_education'
  is_economic_disadvantaged: 'edu.economic_disadvantage'
```

`oneroster:require_staff_assignment`: Should teaching staff function like all other staff types, in that we require a Staff Assignment with an appropriate Staff Classification? Or should we treat staffSectionAssociation as implicitly assigning the Teacher role, regardless of their StaffClassification or whether they even have a StaffAssignment at all? Default: True

`oneroster:classroom_positions`: Only include Staff-Classroom associations when the staff is listed with an appropriate Classroom Position. This would allow, for example, only including the Teacher of Record, and not Aides, Substitutes, or other roles. This should be a list of approved Classroom Position values, or null to leave unrestricted.
Example: 
```yaml
'oneroster:classroom_positions':
  - Teacher of Record
  - Substitute
```

## OneRoster extensions
OneRoster is an extensible standard. Extensions in this package begin with `metadata.edu` and are always on the right-hand side of the table, as specified in the standard.

`metadata.edu.natural_key`: All sourcedIds in this implementation are an MD5 hash of an underlying natural key. The definitions of the columns included in that key are in the [gen_sourced_id macro](macros/gen_sourced_id.sql). The unhashed string is included for clarity in this extension.

`metadata.edu.staff_classification`: The Ed-Fi Staff Classification field, for more
detailed role information. Since Ed-Fi permits multiple staffClassifications, 
but OneRoster 1.1 does not, we have to choose one.

### Department Organizations
OneRoster allows for a type of Education Organization called a `department`.
While the meaning and intended use of this is pretty loose, one use to which it 
can be put is adding another level of organization to courses: rather than have 
a flat list of all courses offered within a district, one can organize them into
subject-level departments. This can aid in navigating lists of courses, as it 
subdivides the list into more manageable units.

By default this package organizes Courses by the Education Organization 
that owns it in Ed-Fi. However we can enable departmental sorting with a 
configuration like this:

```
# enable the Course Departments feature
'oneroster:use_course_departments': true
# set the column name that will be used to define departments (must be in `dim_course`)
'oneroster:course_dept_column': academic_subject
```

This will create a new set of `department` organizations within `orgs`: one for 
each Academic Subject offered by each Ed Org, and will link the courses to this 
department rather than the defining Ed Org. 
