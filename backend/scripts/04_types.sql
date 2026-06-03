create type client_reservation as (
                                      id integer,
                                      client_id integer,
                                      restaurant_name varchar(256),
                                      restaurant_address varchar(512),
                                      city_name varchar(256),
                                      restaurant_phone varchar(50),
                                      datetime timestamp,
                                      number_of_guests integer,
                                      status status_type,
                                      special_requests text
                                  );

drop type if exists restaurant_detail cascade;

create type restaurant_detail as (
                                     id integer,
                                     name varchar(256),
                                     city varchar(256),
                                     address varchar(512),
                                     phone varchar(50),
                                     rating double precision,
                                     price_range integer,
                                     last_reservation_date timestamp,
                                     pending_requests_count integer,
                                     description text
                                 );

create type service_info as (
    day_of_week integer,
    start_time time,
    end_time time
                            );


create type reservation_slot_info as (
                                         slot_datetime timestamp,
                                         slot_time text,
                                         has_enough_capacity boolean
                                     );

