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

3. Staff Classification Mapping
- File name: `xwalk_oneroster_staff_classifications`
- Columns:
  - `staff_classification`: Comes from the Ed-Fi Staff Ed Org Assignment Associations resource, Staff Classification field.
  - `oneroster_role`: Must be one of the [OneRoster RoleType](http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452025) list of values (administrator, aide, guardian, parent, proctor, relative, student, teacher).
4. Class Type Mapping
- File name: `xwalk_oneroster_class_type`
- Columns:
  - `local_course_code`: Comes from the Ed-Fi courseOfferings resource, Local Course Code field.
  - `type`: Must be one of the [OneRoster classType](https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452021) list of values (homeroom, scheduled).