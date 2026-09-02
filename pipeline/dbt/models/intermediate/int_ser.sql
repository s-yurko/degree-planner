-- SER dictionary: one row per (rule, course_code), exploded 
-- from all_courses_including_courses_from_smart_lists

-- course_code is everything before " - " in the column

-- rules with zero courses (placement/proficiency exams) get one course_code = 'TEST' row
-- instead, with a meaning string, so combination leaves resolve uniformly

-- duplicate SER keys sometimes list genuinely different courses across source rows, 
-- so rather than silently picking one, those get unioned and flagged with
-- is_merged_from_conflicting_dupes

with source as (
    select *
    from {{ ref('stg_student_eligibility_rules') }}
    where student_eligibility_rule is not null
),

exploded as (
    select
        s.student_eligibility_rule,
        s._source_row,
        nullif(trim(split_part(trim(both E' \t\r\n' from raw_course), ' - ', 1)), '') as course_code
    from source s,
         lateral regexp_split_to_table(
             s.all_courses_including_courses_from_smart_lists, E'\r?\n'
         ) as raw_course
),

cleaned as (
    select student_eligibility_rule, _source_row, course_code
    from exploded
    where course_code is not null
),

-- course codes listed by each source row, used to detect conflicting duplicate keys
per_source_set as (
    select
        student_eligibility_rule,
        _source_row,
        array_agg(distinct course_code order by course_code) as course_set
    from cleaned
    group by 1, 2
),

conflict_flags as (
    select
        student_eligibility_rule,
        count(*) > 1 and count(distinct course_set) > 1 as is_merged_from_conflicting_dupes
    from per_source_set
    group by 1
),

course_rows as (
    select distinct
        c.student_eligibility_rule,
        c.course_code,
        null::text as meaning,
        f.is_merged_from_conflicting_dupes
    from cleaned c
    join conflict_flags f using (student_eligibility_rule)
),

-- rules with no course rows anywhere: one TEST row; distinct on picks the lowest
-- source row so a duplicated key still yields a single row
test_rows as (
    select distinct on (student_eligibility_rule)
        student_eligibility_rule,
        'TEST'::text as course_code,
        case when use_custom_meaning
             then custom_eligibility_rule_meaning
             else eligibility_rule_meaning
        end          as meaning,
        false        as is_merged_from_conflicting_dupes
    from source
    where not exists (
        select 1 from cleaned c where c.student_eligibility_rule = source.student_eligibility_rule
    )
    order by student_eligibility_rule, _source_row
)

select student_eligibility_rule, course_code, meaning, is_merged_from_conflicting_dupes from course_rows
union all
select student_eligibility_rule, course_code, meaning, is_merged_from_conflicting_dupes from test_rows
