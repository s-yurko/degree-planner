-- cleaned 1:1 mirror of raw.student_eligibility_rules

with source as (
    select * from {{ source('raw', 'student_eligibility_rules') }}
)

select
    _source_row::int                                            as _source_row,
    {{ clean_string('_source_file') }}                          as _source_file,
    _ingested_at::timestamptz                                   as _ingested_at,

    {{ clean_string('student_eligibility_rule') }}              as student_eligibility_rule,
    {{ clean_string('eligibility_rule_meaning') }}              as eligibility_rule_meaning,
    {{ clean_string('custom_eligibility_rule_meaning') }}       as custom_eligibility_rule_meaning,
    {{ yn_to_bool('use_custom_meaning') }}                      as use_custom_meaning,
    {{ clean_string('smart_lists') }}                           as smart_lists,
    {{ clean_string('all_courses_including_courses_from_smart_lists') }} as all_courses_including_courses_from_smart_lists
from source
