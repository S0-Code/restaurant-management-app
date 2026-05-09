set search_path to public;

-- INSERT correct : status pending
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: création réservation avec statut pending correct';

        insert into users (email, full_name, password, role)
        values ('client_status_pending@test.com', 'Client Status Pending', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Status Pending', 'Rue Test', 'Bruxelles', '+32 485 11 11 11', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type);
    end;
$test$;
rollback;


-- INSERT incorrect : status confirmed
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: création réservation avec statut confirmed incorrect';

        insert into users (email, full_name, password, role)
        values ('client_status_confirmed@test.com', 'Client Status Confirmed', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Status Confirmed', 'Rue Test', 'Bruxelles', '+32 485 22 22 22', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        perform should_fail(format(
                                    $sql$
            insert into reservations (client, restaurant, number_of_guests, datetime, status)
            values (%s, %s, 2, '2026-11-15 19:00:00', 'confirmed'::status_type);
        $sql$,
                                    client_id,
                                    restaurant_id
                            ), 'raise_exception');
    end;
$test$;
rollback;


-- UPDATE correct : pending -> confirmed
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: transition pending -> confirmed correcte';

        insert into users (email, full_name, password, role)
        values ('client_pending_confirmed@test.com', 'Client Pending Confirmed', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Pending Confirmed', 'Rue Test', 'Bruxelles', '+32 485 33 33 33', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 4,  2)
        returning id into table_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'::status_type
        where id = reservation_id;
    end;
$test$;
rollback;


-- UPDATE correct : pending -> cancelled
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: transition pending -> cancelled correcte';

        insert into users (email, full_name, password, role)
        values ('client_pending_cancelled@test.com', 'Client Pending Cancelled', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Pending Cancelled', 'Rue Test', 'Bruxelles', '+32 485 44 44 44', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        update reservations
        set status = 'cancelled'::status_type
        where id = reservation_id;
    end;
$test$;
rollback;


-- UPDATE incorrect : pending -> completed
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: transition pending -> completed incorrecte';

        insert into users (email, full_name, password, role)
        values ('client_pending_completed@test.com', 'Client Pending Completed', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Pending Completed', 'Rue Test', 'Bruxelles', '+32 485 55 55 55', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        perform should_fail(format(
                                    $sql$
            update reservations
            set status = 'completed'
            where id = %s;
        $sql$,
                                    reservation_id
                            ), 'raise_exception');
    end;
$test$;
rollback;


-- UPDATE correct : confirmed -> completed
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: transition confirmed -> completed correcte';

        insert into users (email, full_name, password, role)
        values ('client_confirmed_completed@test.com', 'Client Confirmed Completed', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Confirmed Completed', 'Rue Test', 'Bruxelles', '+32 485 66 66 66', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        insert into tables (restaurant, table_number,  capacity)
        values (restaurant_id, 4 ,  2)
        returning id into table_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'::status_type
        where id = reservation_id;

        update reservations
        set status = 'completed'::status_type
        where id = reservation_id;
    end;
$test$;
rollback;


-- UPDATE correct : confirmed -> cancelled
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: transition confirmed -> cancelled correcte';

        insert into users (email, full_name, password, role)
        values ('client_confirmed_cancelled@test.com', 'Client Confirmed Cancelled', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Confirmed Cancelled', 'Rue Test', 'Bruxelles', '+32 485 77 77 77', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 4, 2)
        returning id into table_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'::status_type
        where id = reservation_id;

        update reservations
        set status = 'cancelled'::status_type
        where id = reservation_id;
    end;
$test$;
rollback;


-- UPDATE correct : confirmed -> pending
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: transition confirmed -> pending correcte';

        insert into users (email, full_name, password, role)
        values ('client_confirmed_pending@test.com', 'Client Confirmed Pending', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Confirmed Pending', 'Rue Test', 'Bruxelles', '+32 485 88 88 88', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 4, 2)
        returning id into table_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'::status_type
        where id = reservation_id;

        update reservations
        set status = 'pending'::status_type
        where id = reservation_id;
    end;
$test$;
rollback;


-- UPDATE incorrect : completed -> confirmed
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: transition completed -> confirmed incorrecte';

        insert into users (email, full_name, password, role)
        values ('client_completed_confirmed@test.com', 'Client Completed Confirmed', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Completed Confirmed', 'Rue Test', 'Bruxelles', '+32 485 99 99 99', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');


        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 4, 2)
        returning id into table_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'::status_type
        where id = reservation_id;

        update reservations
        set status = 'completed'::status_type
        where id = reservation_id;

        perform should_fail(format(
                                    $sql$
            update reservations
            set status = 'confirmed'::status_type
            where id = %s;
        $sql$,
                                    reservation_id
                            ), 'raise_exception');
    end;
$test$;
rollback;


-- UPDATE incorrect : cancelled -> pending
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: transition cancelled -> pending incorrecte';

        insert into users (email, full_name, password, role)
        values ('client_cancelled_pending@test.com', 'Client Cancelled Pending', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto Cancelled Pending', 'Rue Test', 'Bruxelles', '+32 485 10 10 10', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '22:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending'::status_type)
        returning id into reservation_id;

        update reservations
        set status = 'cancelled'::status_type
        where id = reservation_id;

        perform should_fail(format(
                                    $sql$
            update reservations
            set status = 'pending'::status_type
            where id = %s;
        $sql$,
                                    reservation_id
                            ), 'raise_exception');
    end;
$test$;
rollback;