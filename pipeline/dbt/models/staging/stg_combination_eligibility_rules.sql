-- cleaned 1:1 mirror of raw.combination_eligibility_rules
-- "order" is a sql reserved word, renamed to combination_order

with source as (
    select * from {{ source('raw', 'combination_eligibility_rules') }}
)

select
    _source_row::int                                                as _source_row,
    {{ clean_string('_source_file') }}                              as _source_file,
    _ingested_at::timestamptz                                       as _ingested_at,

    {{ clean_string('student_eligibility_rule') }}                  as student_eligibility_rule, -- parent
    {{ clean_string('eligibility_rule_meaning') }}                  as eligibility_rule_meaning,
    {{ clean_string('custom_eligibility_rule_meaning') }}           as custom_eligibility_rule_meaning,
    {{ yn_to_bool('use_custom_meaning') }}                          as use_custom_meaning,
    {{ clean_string('"order"') }}                                   as combination_order,
    {{ clean_string('selector_for_combination_eligibility_rule') }} as selector_for_combination_eligibility_rule,
    {{ clean_string('open_parenthesis') }}                          as open_parenthesis,
    {{ clean_string('student_eligibility_rules') }}                 as student_eligibility_rules, -- child
    {{ clean_string('and_or') }}                                    as and_or,
    {{ clean_string('close_parenthesis') }}                         as close_parenthesis,
    {{ clean_string('number_of_rules') }}::int                      as number_of_rules
from source
