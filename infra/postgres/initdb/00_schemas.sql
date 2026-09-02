-- runs once on first cluster init (via /docker-entrypoint-initdb.d)
-- raw is the ETL landing zone, 
-- analytics is the profile's required default target, to catch junk
-- dbt creates its own schemas (staging/intermediate/marts)

create schema if not exists raw;
create schema if not exists analytics;
