set search_path to public;

-- 1) INSERT correct : heure correspond à un slot (multiple de slot_duration)
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Heure conforme au slot correct (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br05_insert_ok@test.com', 'Client BR-05 OK', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Restaurant BR-05 OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '23:00:00');

        -- 19:00 → OK (minute = 0, multiple de 30)
        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00');
    end;
$test$;
rollback;


-- 2) INSERT incorrect : heure ne correspond pas au slot
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Heure non conforme au slot incorrect (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br05_insert_ko@test.com', 'Client BR-05 KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Restaurant BR-05 KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 13', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '23:00:00');

        -- 19:10 → KO (10 % 30 ≠ 0)
        perform should_fail($$
            insert into reservations (client, restaurant, number_of_guests, datetime)
            values ($$ || client_id || $$, $$ || restaurant_id || $$, 2, '2026-11-15 19:10:00')
        $$, 'P0001');
    end;
$test$;
rollback;


-- 3) UPDATE correct : modification vers heure valide
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: Heure conforme au slot correct (update)';

        insert into users (email, full_name, password, role)
        values ('client_br05_update_ok@test.com', 'Client BR-05 Update OK', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Restaurant BR-05 Update OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 14', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '23:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00')
        returning id into reservation_id;

        -- 19:30 → OK
        update reservations
        set datetime = '2026-11-15 19:30:00'
        where id = reservation_id;
    end;
$test$;
rollback;


-- 4) UPDATE incorrect : modification vers heure invalide
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: Heure non conforme au slot incorrect (update)';

        insert into users (email, full_name, password, role)
        values ('client_br05_update_ko@test.com', 'Client BR-05 Update KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Restaurant BR-05 Update KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 15', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '23:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00')
        returning id into reservation_id;

        -- 19:17 → KO
        perform should_fail($$
            update reservations
            set datetime = '2026-11-15 19:17:00'
            where id = $$ || reservation_id ||
            $$$$, 'raise_exception');
    end;
$test$;
rollback;