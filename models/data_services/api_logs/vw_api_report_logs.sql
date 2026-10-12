

with source as (

    select 
        SRC_FILENAME,
        API,
        CHANNEL,
        "ERROR_MESSAGE",
        LEGAL_ENTITY_NAME,
        case    when lower(channel) = 'client-credentials' then legal_entity_name
                when lower(channel) = 'authorization_code' and client_name is not null then client_name
                else pms
        end as integrator ,
        OB_CODE,
        PMS,
        PRODUCT,
        REQUEST_BODY,
        REQUEST_QRY_STRING,
        REQUEST_TIMESTAMP,
        REQUEST_TIMESTAMP_AEST,
        REQUEST_URL,
        RESPONSE_BODY,
        RESPONSE_HEADERS,
        RESPONSE_STATUS,
        SUBSCRIBER_ID,
        SUBSCRIBER_TYPE,
        USERNAME,
        UUID,
        WORKSPACE_ID,
        CLIENT_NAME,
        SRC_INSERTED_AT,
        INSERTED_AT
     from {{ ref('curate_api_report_logs') }}

),

renamed as (

    select
        SRC_FILENAME,
        API,
        CHANNEL,
        "ERROR_MESSAGE",
        LEGAL_ENTITY_NAME,
        case    WHEN integrator IN ('pxa_ac_cats', 'GaPqtWrHKXqXdhEvcQ0DpAz3bd6clACU', 'PEXA Exchange - Cats Conveyancing') THEN 'CATS'
                WHEN integrator IN ('UBsdvL45Qt24zbzVQFd2qMfPnVo0xw71', 'PEXA Exchange - WorkCloud') THEN 'ActionStep'
                WHEN integrator IN ('pxa_cc_anz', 'settlement.lex.anzx.anz.com', 'fCkaBq9FznhOlr2HkHCKAfuBJZLAcxX5') THEN 'ANZ'
                WHEN integrator IN ('IZvHdIHeWjeCPabKdkhUsWHJsoPRj5Rv') THEN 'ANZ Plus'
                WHEN integrator IN ('pxa_cc_bankaust', 'B7LkbfqL5zuCK5mCCLN6ZmiWsuXOMbt8') THEN 'Bank Australia'
                WHEN integrator IN ('pxa_cc_bankwest', 'tibco.bankwest.com.au', 'settlementsapi-prd.bankwest.com.au', 'pxa_cc_bankwestsetts', 'GAY5IvQAgR74kKe6QiK5zsHvZhh6CrXQ', 'tCZ2uUYQb9N3t8T7tGNuLgdVgjZCql9C') THEN 'Bankwest'
                WHEN integrator IN ('mp.prod.s3.chp.cba', 'pxa_cc_cba', 'A7jM7GYrCPvsQZBDR7goNpH8Ih4hsNbg') THEN 'Commonwealth Bank Australia'
                WHEN integrator IN ('pxa_ac_contactsLaw', 'vlMOtrmPSJCf067IWWRaWpdgBhiWyLD2', 'PEXA Exchange - Contacts Law') THEN 'Contacts Law'
                WHEN integrator IN ('*.conveyancing.com.au', 'pxa_cc_comauconvey') THEN 'Conveyancing.com.au'
                WHEN integrator IN ('PARTNERS OF COOPER GRACE WARD') THEN 'Cooper Grace Ward'
                WHEN integrator IN ('pxa_ropc_cgw', 'pxa_cc_cgw', 'oYHW0Fg9kvMnQ9dTvcwwQzI8TyLziFm8') THEN 'Cooper Grace Ward Lawyers'
                WHEN integrator IN ('pxa_ac_dentons', 'jmutiODIXfg99VvjUEAVqo4EcuSj9g7n', 'PEXA Exchange - Dentons') THEN 'Dentons'
                WHEN integrator IN ('pxa_cc_egl') THEN 'Emmett Grace Lawyers'
                WHEN integrator IN ('G6YaVfZ5ZEqPnjsQvavfgguwVJyc3Usr') THEN 'Firstmac'
                WHEN integrator IN ('pexa.firstms.com', 'pxa_cc_firstms', 'vjJB9tRGkopCJ4P9pKSWLFjGdlBlbWw7') THEN 'FMS'
                WHEN integrator IN ('PARTNERS OF GADENS LAWYERS') THEN 'Gadens Lawyers'
                WHEN integrator IN ('*.qld.gadens.com.au') THEN 'Gadens Queensland (Brisbane)'
                WHEN integrator IN ('*.gadens.com', 'pxa_cc_gadens', '9RL2nSn7TaGbGLwS3UbRzg5PjuDjuAJr') THEN 'Gadens Victoria'
                WHEN integrator IN ('*.galilee.com.au', 'pxa_cc_galilee', '3G2RVhf9br1ioosYkO5Io7fPlxNia0ar') THEN 'Galilee Solicitors'
                WHEN integrator IN ('pxa_ac_globalX', 'Yo7haKPkMsMZR73MH42MPhoFgpz7cjYa', 'PEXA Exchange - GlobalX') THEN 'GlobalX'
                WHEN integrator IN ('pexaint.greenmortgagelawyers.com', 'xER9NzwZlY97cvAFHxnlYGPVCzX0TuJn', 'GREEN MORTGAGE LAWYERS PTY LTD') THEN 'GREEN MORTGAGE LAWYERS PTY LTD'
                WHEN integrator IN ('pxa_ac_infotrack', 'aHFfZ0eeLfcFDLtgUphMVLUitRzfWpUY', 'PEXA Exchange - InfoTrack') THEN 'InfoTrack'
                WHEN integrator IN ('lawlogic.com.au', 'pxa_cc_keylaw', 'afjrlYdqeGmr5osD4kNZxh3OCvfSYL3x') THEN 'Keylaw and Hains Solicitors'
                WHEN integrator IN ('dmTrqdSzS3l6J3vf92UplUJVl8xXq7fx') THEN 'Kong Web Session Management Client for PEXA Exchange, Plus and Planner'
                WHEN integrator IN ('pxa_cc_landers', 'bZR1fr2xdt5lTZqCczYLxEKo1NpWYPOn', 'PARTNERS OF LANDER & ROGERS') THEN 'Lander & Rogers'
                WHEN integrator IN ('*.legalstream.com.au', 'pxa_cc_legalstream', 'Gx9L5MYsNyjSRkv3N1uq6OTkEowCpP8D', 'IifTysUZL8RQO3NXinbzEHMjcLx3AKL0', '4gUZ9C2FYIOjatiIsJEc0bGOvFibpSVs') THEN 'LegalStream'
                WHEN integrator IN ('pxa_ac_lexisNexis', 'SOk7Zgi9GoRSNPjQy74zai6cOUXDIyyJ', 'PEXA Exchange - Lexis Nexis Law') THEN 'LexisNexis'
                WHEN integrator IN ('c4KTPgjR9M5CSZ0lFc9dajPxzrTa5VHe') THEN 'Lextech'
                WHEN integrator IN ('fmc2pexa.firstmac.com.au', 'pxa_cc_firstmac') THEN 'LIVE LAWYER PTY LTD'
                WHEN integrator IN ('pxa_cc_lodgex', 'aXssqvfcyUrximqkULaoci9lmZdrSGwQ', 'lapp.lodgex.com.au') THEN 'LODGEX LEGAL PTY. LTD'
                WHEN integrator IN ('pxa_ropc_maddocks', 'pxa_cc_maddocks', 'ic9ebaFndoO4r9WZ3nYs4fxkVsbZNpeY', 'PARTNERS OF MADDOCKS') THEN 'Maddocks'
                WHEN integrator IN ('PARTNERS OF MAKINSON D''APICE', '*.makdap.com.au', 'pxa_cc_makdap', 'bwx5etQfceQGSYM4qJKOWnOUAQYiYnBV') THEN 'Makinson dApice Lawyers'
                WHEN integrator IN ('pxa_cc_karimbla13', 'pxa_cc_karimbla25', 'pxa_cc_karimbla32', 'pxa_cc_karimbla33', 'pxa_cc_karimbla36', 'pxa_cc_karimbla39', 'pxa_cc_karimbla40', 'pxa_cc_karimbla41', 'pxa_cc_karimbla45', 'pxa_cc_karimbla46', 'pxa_cc_karimbla47', 'pxa_cc_karimbla48', 'pxa_cc_karimbla49', 'pxa_cc_karimbla51', 'pxa_cc_karimbla52', 'pxa_cc_karimbla54', 'pxa_cc_karimbla55', 'pxa_cc_karimbla56', 'pxa_cc_karimbla58', 'pxa_cc_karimbla59', 'pxa_cc_karimbla62', 'pxa_cc_meritonfinance', 'pxa_cc_rhodespeninsula', 'pxa_ropc_meriton', '60FhX9aNvfBwnofXsQEGsGijxSU0icXS', 'PZsSfvWy18HVFcGbs6ietU9BqF6sWjZK', 'suwHnH5QFMFHO7wudcsDiuYruyPpYCWh', 'vlkg7C5dmBfff6FFzGBsFmezaJrruV3u', '0eVF8Qd3KdsjeynAuauDW1lmznj4PRTL', '2CbdZf2Vtmwl8wj7W6gtDPgodc26EEkl', 'BrX0KPnMbcD7I8XePkw5Z1Tkl7GV9zQH', 'iGrCb40Hb1MHFpgpcxbbvFiYB1YdMegw', 'IyQpgEVpejgm2FFKRby0xVEudNRCreig', 'IZl306AADivjh85gXQKMcVCSe06Rc5Qw', 'JemUUex1X3rKK79rTpAoUM1I8yL9W2r6', 'N0Y2Ayng35z19tXeB4WhVXgvaLiCuNbr', 'OpVWDaEt00QpWOa0pH9DpIypc4gV7SSt', 'oypiqtbz9TuYOAfADDpnRtVQh7mluMP6', 'qokvR992cUjZ9EWxM8N7D9gV0ytyCeTi', 'uAJhcv7cEkPu9j2W30nTxH6IBhJ3zYEB', 'ViguQYwC8LDmopG1nehWXxrZDxS1Bj1M', 't0VuIESI5rqmWOWtllp1wKB6L42Bo8j5', 'KARIMBLA PROPERTIES (NO. 13) PTY. LIMITED', 'KARIMBLA PROPERTIES (NO. 25) PTY. LIMITED', 'KARIMBLA PROPERTIES (NO. 39) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 40) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 41) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 48) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 49) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 51) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 52) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 54) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 55) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 56) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 58) PTY LIMITED', 'KARIMBLA PROPERTIES (NO. 59) PTY LIMITED', 'KARIMBLA PROPERTIES (NO.45) PTY LTD', 'KARIMBLA PROPERTIES (NO.46) PTY LTD', 'KARIMBLA PROPERTIES (NO.47) PTY LTD') THEN 'Meriton'
                WHEN integrator IN ('*.msanational.com.au', 'pxa_cc_msa', 'pexa.msanational.com.au', 'HrvDLiNBv1yPJYGLjx3uVYz3BJ6oFTkB') THEN 'MSA National'
                WHEN integrator IN ('nab-server-prod', 'pxa_cc_nab', 'RVM1LdVm4wcVdppUIe0jxOG5xps1782b') THEN 'National Australia Bank'
                WHEN integrator IN ('pxa_ac_nebulaw', 'FddjY3L8Fp7jOhOGUlY0Gi9ytmuRtRE5') THEN 'NebuLAW Legal Practice Management System'
                WHEN integrator IN ('pxa_ac_opex', 'DG7v2V5FhHBUP8yUFmTP0V1gh4Q9y2xJ', 'PEXA Exchange - OPEX') THEN 'OPEX'
                WHEN integrator IN ('G01ip0nX0nRekjNHPDwMLEUQWwV8IMiD') THEN 'PEXA Projects'
                WHEN integrator IN ('pxa_cc_provey', 'c0pQ0s0IShzK5zmreGdI3Abf6L8mHw8r') THEN 'Provey Conveyancing'
                WHEN integrator IN ('pxa_ac_realtimeConveyancer', 'vpW2EBsoN9DkDUvFKlrkUkhUb6zACBUm', 'PEXA Exchange - Realtime Conveyancer', 'Realtime Conveyancer') THEN 'Realtime Conveyancer'
                WHEN integrator IN ('ycQrXJIf3JB51aagMy2Lac2jFjNGIk0g') THEN 'REB conveyancing'
                WHEN integrator IN ('f0m5JkKZHujRrEWglVDQa7GjuxBrPR9h') THEN 'Sales Funder'
                WHEN integrator IN ('PEXA Exchange - Setts Plus') THEN 'Setts Plus'
                WHEN integrator IN ('pxa_ac_settsplus', 'oAVmAstBhwDHA8WntY9oMUwZfKjOnZv2') THEN 'SettsPlus'
                WHEN integrator IN ('pxa_cc_spectrum', 'Spectrum Solutions', 'i90rLgLV4SvlgLlZVTvVZc0YUPNBm4RA') THEN 'Spectrum'
                WHEN integrator IN ('pxa_cc_stgeorge', '5OxbOvifIxpjZZTjHkrBdDzPitzmA4Js') THEN 'St George'
                WHEN integrator IN ('pxa_cc_awbidco4', 'pxa_cc_awbidco5', 'pxa_cc_awbidco6', 'pxa_cc_awbidco8', 'pxa_cc_scplyra', 'pxa_cc_stocklandarmstrongcreek', 'pxa_cc_stocklanddevelopment', 'pxa_cc_stocklandhighlands', 'pxa_cc_stocklandkawanawaters', 'pxa_cc_stocklandnorthlakes', 'pxa_cc_stocklandwadevelopment', 'pxa_ropc_stockland', '4NpMjDG8c03KJ7yDhYUJEqICnGMKLpna', '5Ffw5p0h1Cj2ZzwcUWQs5HvXMHgihcc5', '7qUrxm2tazL92VLmWVbvrWxfOorWwe0V', 'hdcGdOzLSzIzClqiQ4lQ2c5O9oU1iZc8', 'MlWGNbwwUmr7mJF8xrERnJ9aj91HBBw2', 't7c5dcHNhoPuTh8LrEf5rMNMtHkGnOID', '7fWVTqqcwvH5QNUzMvRgqbXVvLasC4pU', 'asn6GkEOuTC00jsxav9xZpq69TqacaUD', 'OGYRUhkoyM1lI6PGPYxMxVlJYVanqsx9', 'k2NYuCP54kRo8emqJUEM4ClcUQSziHU0', 'ARMSTRONG CREEK PTY LTD', 'AW BIDCO 4 PTY LIMITED', 'AW BIDCO 5 PTY LIMITED', 'AW BIDCO 6 PTY LIMITED', 'AW BIDCO NO. 8 PTY LIMITED', 'SCP LYRA PTY LTD', 'STOCKLAND DEVELOPMENT PTY LIMITED', 'STOCKLAND HIGHLANDS PTY LIMITED', 'STOCKLAND KAWANA WATERS PTY LIMITED', 'STOCKLAND WA DEVELOPMENT PTY LIMITED') THEN 'Stockland'
                WHEN integrator IN ('PBNEUIPATH4015.int.corp.sun') THEN 'Suncorp'
                WHEN integrator IN ('pxa_ac_trisearch', 'srufdoU9B3nGJ9TnnCltAuLVR3PDI9J0', 'PEXA Exchange - Trisearch', 'triSearch') THEN 'Trisearch'
                WHEN integrator IN ('pxa_cc_unloan', 'FKTbqh41z2nQqsReFPAKXk2DfrfQUiYU') THEN 'Unloan'
                WHEN integrator IN ('wx0Dl7rPvdY3DLCHoccrGekUqyWcy9Pt') THEN 'Unloan Direct'
                WHEN integrator IN ('pxa_cc_westpac', 'YgXwnqEQYfv4gzo7swUmcbkaD1FYgUTC') THEN 'Westpac'
                WHEN integrator IN ('pxa_ac_workcloud') THEN 'WorkCloud'
                else integrator
        end as integrator_name ,
        OB_CODE,
        PMS,
        PRODUCT,
        REQUEST_BODY,
        REQUEST_QRY_STRING,
        REQUEST_TIMESTAMP,
        REQUEST_TIMESTAMP_AEST,
        REQUEST_URL,
        RESPONSE_BODY,
        RESPONSE_HEADERS,
        RESPONSE_STATUS,
        SUBSCRIBER_ID,
        SUBSCRIBER_TYPE,
        USERNAME,
        UUID,
        WORKSPACE_ID,
        CLIENT_NAME,
        SRC_INSERTED_AT,
        INSERTED_AT

    from source

)


select * from renamed