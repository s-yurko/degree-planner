-- POS mart: one row per (pos, year, academic_requirement)

-- year is hardcoded to 2022. Later, it will be filled with real data 
-- to version the changes in the programs

with pos_requirements as (
    select pos, academic_requirement
    from {{ ref('int_pos') }}
)

select
    pos,
    2022                   as year,   -- FAKE PLACEHOLDER
    academic_requirement
from pos_requirements
