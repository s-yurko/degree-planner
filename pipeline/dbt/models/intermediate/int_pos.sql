-- POS requirements, resolved: one row per (pos, academic_requirement)
-- stage 2 of 2 (see int_pos_requirements_exploded.sql for the first)

-- this stage builds out the major focuses (each focus = its own requirements + its parent major's),
-- and passes majors and minors through as-is

with base as (
    select * from {{ ref('int_pos_requirements_exploded') }}
),

majors_and_minors as (
    select program_of_study as pos, academic_requirement
    from base
    where program_type in ('Major', 'Minor')
),

focus_own as (
    select program_of_study as pos, parent_program_of_study, academic_requirement
    from base
    where program_type = 'Major Focus'
),

-- each focus also inherits its parent major's requirements
focus_from_parent as (
    select f.pos, p.academic_requirement
    from (select distinct pos, parent_program_of_study from focus_own) f
    join base p
      on  p.program_of_study = f.parent_program_of_study
      and p.program_type     = 'Major'
),

-- union (not union all) dedups where a focus re-lists a parent requirement
focuses as (
    select pos, academic_requirement from focus_own
    union
    select pos, academic_requirement from focus_from_parent
)

select pos, academic_requirement from majors_and_minors
union all
select pos, academic_requirement from focuses
