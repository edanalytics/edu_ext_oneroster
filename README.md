# edu_ext_oneroster
OneRoster CSV standard in the EDU framework

## Required Seed Files
1. Academic Sessions Types Mapping
- File name: `xwalk_oneroster_academic_sessions_types`
- Columns:
  - `session_name`: Comes from the Ed-Fi Sessions resource, Session Name field.
  - `type`: Must be one of the [OneRoster sessionType](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452027) list of values (gradingPeriod, semester, schoolYear, term).

2. Classroom Positions Primary Teacher Mapping
- File name: `xwalk_oneroster_classroom_positions`
- Columns:
  - `classroom_position`: Comes from the Ed-Fi Staff Section Associations resource, Classroom Position field.
  - `is_primary`: TRUE if this is the primary teacher role, FALSE otherwise. FALSE for students.