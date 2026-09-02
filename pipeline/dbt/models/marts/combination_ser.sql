-- combination SER mart: one row per (student_eligibility_rule, combination_order, child_rule)

-- almost identical to int_combination_ser, but materializes the table and
-- renames selector_for_combination_eligibility_rule to selector

select
    student_eligibility_rule,
    combination_order,
    open_parenthesis,
    child_rule,
    and_or,
    close_parenthesis,
    selector_for_combination_eligibility_rule as selector,
    number_of_rules
from {{ ref('int_combination_ser') }}
