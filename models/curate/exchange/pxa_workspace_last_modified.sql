{{
    config(
        materialized='incremental',
        unique_key='workspace_id',
        merge_exclude_columns = ['inserted_at'],
        transient=false
    )
}}

select 
    workspace_id,
    max(last_modified) as last_modified,
    max(version) as version,
    max(extraction_start_ts) as extraction_start_ts,
    max(inserted_at) as src_delta_extract_ts , 
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from {{ ref('stg_pxa_workspace_last_modified') }}
where {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
group by workspace_id
