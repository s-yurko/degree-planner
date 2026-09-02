-- cleaned 1:1 mirror of raw.academic_requirements

with source as (
    select * from {{ source('raw', 'academic_requirements') }}
)

select
    _source_row::int                                     as _source_row,
    {{ clean_string('_source_file') }}                   as _source_file,
    _ingested_at::timestamptz                            as _ingested_at,

    {{ clean_string('program_of_study') }}               as program_of_study,
    {{ clean_string('pos_refid') }}                      as pos_refid,
    {{ clean_string('academic_requirement') }}           as academic_requirement,
    {{ clean_string('acareq_refid') }}                   as acareq_refid,
    {{ clean_string('requirement_name') }}               as requirement_name,
    {{ clean_string('student_eligibility_rule') }}       as student_eligibility_rule,
    {{ clean_string('eligibility_rule_meaning') }}       as eligibility_rule_meaning,
    {{ clean_string('eligrule_type') }}                  as eligrule_type,
    {{ clean_string('cf_lrv_elig_rule_smart_lists') }}   as cf_lrv_elig_rule_smart_lists,
    {{ clean_string('cf_lrv_elig_rule_courses') }}       as cf_lrv_elig_rule_courses,
    {{ clean_string('cf_lrv_elig_rule_smart_list_courses') }} as cf_lrv_elig_rule_smart_list_courses
from source
