{{
  config(
    tags = ['bypass_rls']
    )
}}
select 
    '1.0' as "manifest.version",
    '1.1' as "oneroster.version",
    'bulk' as "file.academicSessions",
    'absent' as "file.categories",
    'bulk' as "file.classes",
    'absent' as "file.classResources",
    'bulk' as "file.courses",
    'absent' as "file.courseResources",
    'absent' as "file.demographics",
    'bulk' as "file.enrollments",
    'absent' as "file.lineItems",
    'bulk' as "file.orgs",
    'absent' as "file.resources",
    'absent' as "file.results",
    'bulk' as "file.users",
    'enabledataunion' as "file.systemName",
    'edu' as "file.systemCode"