{% test check_raw_stg_cnt(model,vw_model=none) %}
{%if vw_model==none%}
{%set vw_model = model|replace("stg",'vw')|replace("STAGE","RAW")%}
{%endif%}
with raw_latest as 
(select max(extraction_start_ts)  as raw_last_extract from {{vw_model}}),
 raw_last_day as 
(select  dateadd('hour',-24,max(extraction_start_ts)) as raw_last_day_extract from {{vw_model}}),
stg_latest as
(select max(extraction_start_ts) as stg_last_extract from {{model}}),
raw as (
select count(*) as raw_count from {{vw_model}}
where extraction_start_ts <= (select stg_last_extract from stg_latest)
and extraction_start_ts >= (select raw_last_day_extract from raw_last_day)
),
stage as (
select count(*) as stg_count
from {{model}} 
where extraction_start_ts <= (select stg_last_extract from stg_latest)
and extraction_start_ts >= (select raw_last_day_extract from raw_last_day)
)
select raw_count, stg_count,raw_count-stg_count as diff
from raw full join stage
where (raw_count !=0 
and stg_count !=0)
and raw_count-stg_count !=0
{% endtest %}