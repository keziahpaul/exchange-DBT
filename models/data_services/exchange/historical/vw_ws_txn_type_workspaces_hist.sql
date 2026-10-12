with source as (

    select * from {{ ref('pxa_ws_txn_type_workspaces') }}

),

renamed as (

    select
        workspace_id,
        ws_transaction_type,
      effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed