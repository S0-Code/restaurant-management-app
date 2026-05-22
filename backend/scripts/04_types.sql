create type client_reservation as (
                                      id integer,
                                      restaurant_name varchar(256),
                                      city_name varchar(256),
                                      datetime timestamp,
                                      number_of_guests integer,
                                      status status_type
                                  );

