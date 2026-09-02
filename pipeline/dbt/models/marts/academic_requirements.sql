-- requirement dictionary mart: one row per (academic_requirement, requirement_type, student_eligibility_rule)

-- bucketable types only: course / credit / combination. Grade and test achievement
-- are metadata (surfaced to the student, never scheduled) and are excluded here

with requirements as (
    select academic_requirement, requirement_type, student_eligibility_rule
    from {{ ref('int_academic_requirements') }}
    where requirement_type in ('course', 'credit', 'combination')
)

select distinct
    academic_requirement,
    requirement_type,
    student_eligibility_rule
from requirements
