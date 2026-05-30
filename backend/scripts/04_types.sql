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

