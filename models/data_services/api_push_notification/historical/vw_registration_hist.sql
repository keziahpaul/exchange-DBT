

with source as (

    select * from {{ ref('registration_curate') }}

),

renamed as (

    select
        id 
        ,subscriber_id 
        ,created_at 
        ,deleted 
        ,integrator_id 
        ,type
        ,updated_at_src 
        ,effective_from 
        ,effective_to
        ,inserted_at
        ,updated_at
    
   
    from source
   

)


select * from renamed
