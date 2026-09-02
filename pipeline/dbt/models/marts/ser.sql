-- SER dictionary mart: one row per (student_eligibility_rule, course_code)

-- almost identical to int_ser, but materializes the table and drops
-- is_merged_from_conflicting_dupes, as it's not needed outside of testing

with ser_courses as (
    select student_eligibility_rule, course_code, meaning
    from {{ ref('int_ser') }}
)

select distinct
    student_eligibility_rule,
    course_code,
    meaning
from ser_courses
