with source as (
    select *
    from {{ source('bronze', 'users') }}
),

first_orders as (
    select
        cast(user_uuid as uuid) as user_id,
        min(cast(date as timestamptz)) as first_order_at
    from {{ source('bronze', 'orders') }}
    group by user_id
),

typed as (
    select
        cast(uuid as uuid) as user_id,
        trim(username) as username,
        lower(trim(username)) as username_normalized,
        trim(name) as name,
        upper(trim(sex)) as sex,
        lower(trim(mail)) as email,
        cast(birthdate as date) as original_birthdate,
        split_part(address, chr(10), 1) as street,
        split_part(address, chr(10), 2) as address_line_2
    from source
),

validated as (
    select
        typed.*,
        case
            when original_birthdate is null then false
            when first_order_at is null then true
            when original_birthdate <= cast(first_order_at as date) then true
            else false
        end as birthdate_is_valid
    from typed
    left join first_orders
        on typed.user_id = first_orders.user_id
)

select
    user_id,
    username,
    username_normalized,
    name,
    sex,
    email,

    case
        when birthdate_is_valid then original_birthdate
        else null
    end as birthdate,

    birthdate_is_valid,
    street,

    nullif(
        regexp_extract(
            address_line_2,
            '^(.+), [A-Z]{2} \d{5}$',
            1
        ),
        ''
    ) as city,

    regexp_extract(
        address_line_2,
        '([A-Z]{2}) (\d{5})$',
        1
    ) as state,

    regexp_extract(
        address_line_2,
        '([A-Z]{2}) (\d{5})$',
        2
    ) as zip_code

from validated
