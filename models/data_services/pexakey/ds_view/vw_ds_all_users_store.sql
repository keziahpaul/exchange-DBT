
    select
        date_created,
        date_updated,
        email,
        given_name,
        user_id,
        mobile,
        registration_status,
        surname,
        username,
        organisation_name,
        src_load_ts,
        inserted_at
from {{ ref('all_users_store') }}
   
