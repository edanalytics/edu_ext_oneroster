{{
  config(
    tags = ['bypass_rls'],
    alias = 'manifest'
    )
}}
select $1 as "propertyName", $2 as "value"
from (values 
    ('manifest.version', '1.0'),
    ('oneroster.version', '1.1'),
    ('file.academicSessions', 'bulk'),
    ('file.categories', 'absent'),
    ('file.classes', 'bulk'),
    ('file.classResources', 'absent'),
    ('file.courses', 'bulk'),
    ('file.courseResources', 'absent'),
    ('file.demographics', 'absent'),
    ('file.enrollments', 'bulk'),
    ('file.lineItems', 'absent'),
    ('file.orgs', 'bulk'),
    ('file.resources', 'absent'),
    ('file.results', 'absent'),
    ('file.users', 'bulk'),
    ('file.systemName', 'enabledataunion'),
    ('file.systemCode', 'edu')
  )