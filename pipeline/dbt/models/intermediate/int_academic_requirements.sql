-- requirement dictionary: one row per (academic_requirement, requirement_type, student_eligibility_rule)

-- splitting bucketable types course/credit/combination from grade/test metadata
-- happens downstream, so nothing gets filtered here beyond blank requirement/rule rows

-- eligibility_rule_meaning is carried for the grade/test metadata mart

with source as (
    select * from {{ ref('stg_academic_requirements') }}
)

select distinct -- academic requirements often repeat in different POSes
    academic_requirement,
    case eligrule_type
        when 'Course Requirement' then 'course'
        when 'Credit Requirement' then 'credit'
        when 'Combination'        then 'combination'
        when 'Grade Requirement'  then 'grade'
        when 'Test Achievement'   then 'test'
    end                          as requirement_type,
    student_eligibility_rule,
    eligibility_rule_meaning
from source
where academic_requirement is not null
  and student_eligibility_rule is not null
