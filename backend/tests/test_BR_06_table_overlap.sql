set search_path to public;

/* -------------------------------------------------------------------------
   TESTS BR-06
   Une table ne peut pas faire l'objet de deux réservations terminées
   ou confirmées pour une même date et un même service.
   ------------------------------------------------------------------------- */


/* 1. Insert correct : même service, mais tables différentes */
begin;
do $test$
    declare
        client1_id bigint;
        client2_id bigint;
        restaurant_id bigint;
        table1_id bigint;
        table2_id bigint;
        res1_id bigint;
        res2_id bigint;
    begin
        raise notice 'TEST BR-06: Même service avec deux tables différentes correct';

        insert into users (email, full_name, password, role)
        values ('client_br06_ok1@test.com', 'Client BR06 OK 1', 'Password123.', 'client')
        returning id into client1_id;

        insert into users (email, full_name, password, role)
        values ('client_br06_ok2@test.com', 'Client BR06 OK 2', 'Password123.', 'client')
        returning id into client2_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR06 OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 6, '18:00', '22:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table1_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 2, 4)
        returning id into table2_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client1_id, restaurant_id, 2, '2026-11-14 19:00:00', 'pending')
        returning id into res1_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client2_id, restaurant_id, 2, '2026-11-14 20:00:00', 'pending')
        returning id into res2_id;



        insert into reservation_tables (reservation, "table")
        values
            (res1_id, table1_id),
            (res2_id, table2_id);

        update reservations
        set status = 'confirmed'
        where id in (res1_id, res2_id);

    end;
$test$;
rollback;


/* 2. Insert incorrect : même table, même date, même service */
begin;
do $test$
    declare
        client1_id bigint;
        client2_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res1_id bigint;
        res2_id bigint;
    begin
        raise notice 'TEST BR-06: Même table même date même service incorrect';

        insert into users (email, full_name, password, role)
        values
            ('client_br06_bad1@test.com', 'Client BR06 BAD 1', 'Password123.', 'client')
        returning id into client1_id;

        insert into users (email, full_name, password, role)
        values
            ('client_br06_bad2@test.com', 'Client BR06 BAD 2', 'Password123.', 'client')
        returning id into client2_id;


        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR06 BAD', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 13', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 6, '18:00', '22:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client1_id, restaurant_id, 2, '2026-11-14 19:00:00', 'pending')
        returning id into res1_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client2_id, restaurant_id, 2, '2026-11-14 20:00:00', 'pending')
        returning id into res2_id;

        insert into reservation_tables (reservation, "table")
        values (res1_id, table_id);

        update reservations
        set status = 'confirmed'
        where id = res1_id;

        insert into reservation_tables (reservation, "table")
        values (res2_id, table_id);

        perform should_fail($$
            update reservations
            set status = 'confirmed'
            where id = $$ || res2_id ||
            $$$$, 'raise_exception');
    end;
$test$;
rollback;


/* 3. Update correct : même table, mais service différent */
begin;
do $test$
    declare
        client1_id bigint;
        client2_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res1_id bigint;
        res2_id bigint;
    begin
        raise notice 'TEST BR-06: Même table même date mais service différent correct';

        insert into users (email, full_name, password, role)
        values
            ('client_br06_update_ok1@test.com', 'Client BR06 Update OK 1', 'Password123.', 'client')
        returning id into client1_id;

        insert into users (email, full_name, password, role)
        values
            ('client_br06_update_ok2@test.com', 'Client BR06 Update OK 2', 'Password123.', 'client')
        returning id into client2_id;



        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR06 Update OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 14', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values
            (restaurant_id, 6, '12:00', '14:00'),
            (restaurant_id, 6, '18:00', '22:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client1_id, restaurant_id, 2, '2026-11-14 12:30:00', 'pending')
        returning id into res1_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client2_id, restaurant_id, 2, '2026-11-14 18:30:00', 'pending')
        returning id into res2_id;

        insert into reservation_tables (reservation, "table")
        values
            (res1_id, table_id),
            (res2_id, table_id);

        update reservations
        set status = 'confirmed'
        where id in (res1_id, res2_id);
    end;
$test$;
rollback;


/* 4. Update incorrect : changement de date/heure vers une table déjà occupée */
begin;
do $test$
    declare
        client1_id bigint;
        client2_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res1_id bigint;
        res2_id bigint;
    begin
        raise notice 'TEST BR-06: Changement datetime vers même date même service incorrect';

        insert into users (email, full_name, password, role)
        values
            ('client_br06_update_bad1@test.com', 'Client BR06 Update BAD 1', 'Password123.', 'client')
        returning id into client1_id;

        insert into users (email, full_name, password, role)
        values
            ('client_br06_update_bad2@test.com', 'Client BR06 Update BAD 2', 'Password123.', 'client')
        returning id into client2_id;


        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR06 Update BAD', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 15', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values
            (restaurant_id, 6, '18:00', '22:00'),
            (restaurant_id, 7, '18:00', '22:00');

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client1_id, restaurant_id, 2, '2026-11-14 19:00:00', 'pending')
        returning id into res1_id;

        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client2_id, restaurant_id, 2, '2026-11-15 19:00:00', 'pending')
        returning id into res2_id;

        insert into reservation_tables (reservation, "table")
        values
            (res1_id, table_id),
            (res2_id, table_id);

        update reservations
        set status = 'confirmed'
        where id in (res1_id, res2_id);

        perform should_fail($$
            update reservations
            set datetime = '2026-11-14 20:00:00'
            where id = $$ || res2_id ||
            $$$$, 'raise_exception');
    end;
$test$;
rollback;