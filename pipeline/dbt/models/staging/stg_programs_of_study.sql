-- cleaned 1:1 mirror of raw.programs_of_study

with source as (
    select * from {{ source('raw', 'programs_of_study') }}
)

select
    _source_row::int                                as _source_row,
    {{ clean_string('_source_file') }}              as _source_file,
    _ingested_at::timestamptz                       as _ingested_at,

    {{ clean_string('academic_level') }}            as academic_level,
    {{ clean_string('program_of_study') }}          as program_of_study,
    {{ clean_string('program_type') }}              as program_type,
    {{ clean_string('effective_date') }}::date      as effective_date,
    {{ clean_string('program_focus') }}             as program_focus,
    {{ yn_to_bool('program_focus_required') }}      as program_focus_required,
    {{ clean_string('academic_requirements') }}     as academic_requirements,
    {{ clean_string('default_credentials') }}       as default_credentials,
    {{ clean_string('owning_academic_unit') }}      as owning_academic_unit,
    {{ clean_string('parent_program_of_study') }}   as parent_program_of_study,
    {{ clean_string('program_area') }}              as program_area,
    {{ clean_string('program_coursework_credit') }}::int as program_coursework_credit
from source
