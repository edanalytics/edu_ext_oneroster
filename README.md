# edu_ext_oneroster
OneRoster CSV standard in the EDU framework

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

## Configuration variables
`oneroster:id_prefix`: A prefix to be included in all sourcedIds. By default this is just `tenant_code`, but this can be overridden if a single unique string value is desired for all tenants.

`oneroster:active_school_year`: The school-year on which to build OneRoster files. This should be rotated at year-rollover time, when incoming data from the school year that's about to begin has settled enough to support rostering.

`oneroster:student_email_type`: The email_type that will be preferred for student users. 

## OneRoster extensions
OneRoster is an extensible standard. Extensions in this package begin with `metadata.edu` and are always on the right-hand side of the table, as specified in the standard.

`metadata.edu.natural_key`: All sourcedIds in this implementation are an MD5 hash of an underlying natural key. The definitions of the columns included in that key are in the [gen_sourced_id macro](macros/gen_sourced_id.sql). The unhashed string is included for clarity in this extension.

`metadata.edu.staffClassification`: The Ed-Fi Staff Classification field, for more
detailed role information. Since Ed-Fi permits multiple staffClassifications, 
but OneRoster 1.1 does not, we have to choose one.