set search_path to public;

/*(BR-02) Le nombre de convives d'une réservation confirmée
  ou terminée ne peut pas dépasser la capacité totale des
  tables associées à la réservation.
  Ceci implique qu'une réservation confirmée ou terminée
  doit avoir au moins une table réservée appartenant au
  restaurant de la réservation.*/


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Capacité suffisante correct (update status confirmed)';

        delete from system_time;
        insert into system_time (simulated_time)
        values ('2026-11-17 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br02_update_ok@test.com', 'Client BR02 Update OK', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR02 Update OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 2, '18:00:00', '22:00:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 4, '2026-11-17 19:00:00', 'pending')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'
        where id = reservation_id;

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Nombre de convives supérieur à la capacité incorrect (update)';

        delete from system_time;
        insert into system_time (simulated_time)
        values ('2026-11-17 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br02_update_ko@test.com', 'Client BR02 Update KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR02 Update KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 2, '18:00:00', '22:00:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 2)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-17 19:00:00', 'pending')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        perform should_fail(
                'update reservations
                 set number_of_guests = 4,
                     status = ''confirmed''
                 where id = ' || reservation_id,
                'raise_exception'
                );

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Suppression table associée incorrect (delete reservation_tables)';

        delete from system_time;
        insert into system_time (simulated_time)
        values ('2026-11-17 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br02_rt_delete_ko@test.com', 'Client BR02 RT Delete KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR02 RT Delete KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 2, '18:00:00', '22:00:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 4, '2026-11-17 19:00:00', 'pending')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'
        where id = reservation_id;

        perform should_fail(
                'delete from reservation_tables
                 where reservation = ' || reservation_id || '
               and "table" = ' || table_id || ';
             set constraints trigger_validate_reservation_tables_capacity immediate',
                'raise_exception'
                );

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Réduction capacité table incorrect (update tables)';

        delete from system_time;
        insert into system_time (simulated_time)
        values ('2026-11-17 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br02_table_update_ko@test.com', 'Client BR02 Table Update KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR02 Table Update KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 2, '18:00:00', '22:00:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 4, '2026-11-17 19:00:00', 'pending')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'
        where id = reservation_id;

        perform should_fail(
                'update tables
                 set capacity = 2
                 where id = ' || table_id,
                'raise_exception'
                );

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Suppression table réservée incorrect (delete tables)';

        delete from system_time;
        insert into system_time (simulated_time)
        values ('2026-11-17 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br02_table_delete_ko@test.com', 'Client BR02 Table Delete KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR02 Table Delete KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 2, '18:00:00', '22:00:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 4, '2026-11-17 19:00:00', 'pending')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);

        update reservations
        set status = 'confirmed'
        where id = reservation_id;

        perform should_fail(
                'delete from tables
                 where id = ' || table_id,
                'raise_exception'
                );

    end;
$test$;
rollback;