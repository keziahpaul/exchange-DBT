with source as (

    select * from {{  ref('pxa_settle_sched_history') }}

),

renamed as (

    select
        history_id,
        settlement_schedule_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed