{% docs academic_sessions %}
Academic Session represent durations of time. Typically they are used to describe terms, grading periods, and other durations e.g. school years. 

In OneRoster parlance, Terms and Semesters are units of time in which Classes
are scheduled, and SchoolYears are units of time in which Courses are scheduled.

For this reason it is fully possible to see a 'Year-Round' or 'Full-Year' Term,
which designates a single Class being scheduled for the full year, and is a 
separate concept from the SchoolYear session itself, which is used for Courses.
{% enddocs %} 

{% docs classes %}
A class is an instance of a course, onto which students and teachers are enrolled. A class is typically held within a term.

OneRoster's definition of Classes aligns with Ed-Fi's concept of Sections.
{% enddocs %} 

{% docs courses %}
A Course is a course of study that, typically, has a shared curriculum although it may be taught to different students by different teachers. It is likely that several classes of a single course may be taught in a term. For example, a school runs Grade 9 English in the spring term. There are four classes, each with a different 30 students, taught by 4 different teachers. However the curriculum for each of those four classes is the same - the course curriculum.

Courses in OneRoster align to what Ed-Fi calls Courses.
They are defined here at the district-level, regardless of the owning EdOrg in 
Ed-Fi.
{% enddocs %} 

{% docs enrollments %}
An enrollment is the name given to an individual taking part in a course or class. In the vast majority of cases, users will be students learning in a class, or teachers teaching the class. Other roles are also possible.
{% enddocs %} 

{% docs manifest %}
The manifest describes the OneRoster version, which file types are supported, and in which transport mode.
{% enddocs %} 

{% docs orgs %}
ORG is defined here as a structure for holding organizational information. An ORG might be a school, or it might be a local, statewide, or national entity. ORGs will typically have a parent ORG (up to the national level), and children, allowing a hierarchy to be established.

{% enddocs %} 

{% docs users %}
Users are Students, Teachers, and Parents.

Users are associated with one or more orgs. An extension has been added for StaffClassification.
{% enddocs %} 

{% docs demographics %}
Demographic data about students. Can be extended to include additional fields.

{% enddocs %}

{% docs tenant_code %}
The tenant_code column is included for Row-level security in multi-tenant environments. 

It is not part of the OneRoster standard, and should be excluded from extracts.
{% enddocs %} 
