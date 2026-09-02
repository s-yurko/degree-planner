-- POS requirements: one row per (program_of_study, academic_requirement)
-- stage 1 of 2 (see int_pos.sql for the second)

-- this stage explodes academic_requirements into one row per (program_of_study, academic_requirement),
-- then pulls the university block (requirements shared by every major) into a synthetic
-- 'University' major, so the real majors keep only their unique requirements


with pos as (
    select
        program_of_study,
        program_type,
        parent_program_of_study,
        academic_requirements
    from {{ ref('stg_programs_of_study') }}

    -- ignores second majors and second majors with focus 
    -- as they are pretty much identical to the original
    where program_type in ('Major', 'Major Focus', 'Minor')
      and program_of_study     is not null
      and academic_requirements is not null -- drops req-less programs (like focuses with no own reqs)
),

exploded as (
    select
        program_of_study,
        program_type,
        parent_program_of_study,
        nullif(trim(both E' \t\r\n' from req), '') as academic_requirement
    from pos,
         lateral regexp_split_to_table(academic_requirements, E'\r?\n') as req
),

cleaned as (
    select distinct
        program_of_study,
        program_type,
        parent_program_of_study,
        academic_requirement
    from exploded
    where academic_requirement is not null
),

-- university block
-- requirements that appear in every Major (computed from data, can change year by year)
n_majors as (
    select count(distinct program_of_study) as total
    from cleaned
    where program_type = 'Major'
),

university_block as (
    select academic_requirement
    from cleaned
    where program_type = 'Major'
    group by academic_requirement
    having count(distinct program_of_study) = (select total from n_majors)
),

-- real programs, with the university block stripped out of majors (minors/focuses untouched)
programs as (
    select program_of_study, program_type, parent_program_of_study, academic_requirement
    from cleaned
    where program_type <> 'Major'
       or academic_requirement not in (select academic_requirement from university_block)
),

-- the block as its own synthetic 'University' major
university as (
    select
        'University'    as program_of_study,
        'Major'         as program_type,
        null::text      as parent_program_of_study,
        academic_requirement
    from university_block
)

select program_of_study, program_type, parent_program_of_study, academic_requirement from programs
union all
select program_of_study, program_type, parent_program_of_study, academic_requirement from university
