-- combination SER: one row per (parent_rule, combination_order, child_rule), 
-- exploded from student_eligibility_rules (plural, the child list) -- not to be
-- confused with student_eligibility_rule (singular, the parent id)

-- slot-level metadata (open/close parentheses, and_or, selector, number_of_rules)
-- copies unchanged onto every child in the slot

with source as (
    select * from {{ ref('stg_combination_eligibility_rules') }}
),

exploded as (
    select
        student_eligibility_rule,
        combination_order,
        open_parenthesis,
        nullif(trim(both E' \t\r\n' from child_rule), '') as child_rule,
        and_or,
        close_parenthesis,
        selector_for_combination_eligibility_rule,
        number_of_rules
    from source,
         lateral regexp_split_to_table(student_eligibility_rules, E'\r?\n') as child_rule
    where student_eligibility_rule is not null
)

select distinct
    student_eligibility_rule,
    combination_order,
    open_parenthesis,
    child_rule,
    and_or,
    close_parenthesis,
    selector_for_combination_eligibility_rule,
    number_of_rules
from exploded
where child_rule is not null
