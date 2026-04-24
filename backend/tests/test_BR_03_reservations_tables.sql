/*
(BR-03) Les tables associées à une réservation
doivent appartenir au restaurant de la réservation.
*/


set search_path to public;

-- 1) INSERT correct : la table appartient au même restaurant que la réservation
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Table liée à une réservation du même restaurant correct (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br03_ok@test.com', 'Client BR-03 OK', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone)
        values ('Restaurant BR-03 OK', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_id;

        insert into tables (restaurant, table_number, capacity)
        values (restaurant_id, 1, 4)
        returning id into table_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 7, '18:00:00', '23:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 2, '2026-11-15 19:00:00.000000')
        returning id into reservation_id;

        insert into reservation_tables (reservation, "table")
        values (reservation_id, table_id);
    end;
$test$;
rollback;


-- 2) INSERT incorrect : la table appartient à un autre restaurant
begin;
do $test$
    declare
        client_id bigint;
        restaurant_reservation_id bigint;
        autre_restaurant_id bigint;
        reservation_id bigint;
        table_id bigint;
    begin
        raise notice 'TEST: Table liée à une réservation d’un autre restaurant incorrect (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br03_ko@test.com', 'Client BR-03 KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone)
        values ('Restaurant Réservation BR-03', 'Rue du Test 123', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_reservation_id;

        insert into restaurants (name, address, city, phone)
        values ('Autre Restaurant BR-03', 'Rue Autre Test 123', 'Bruxelles', '+32 485 65 69 13')
        returning id into autre_restaurant_id;

        insert into tables (restaurant, table_number, capacity)
        values (autre_restaurant_id, 1, 4)
        returning id into table_id;


        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_reservation_id, 7, '18:00:00', '23:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_reservation_id, 2, '2026-11-15 19:00:00.000000')
        returning id into reservation_id;

        perform should_fail($$
            insert into reservation_tables (reservation, "table")
            values ($$ || reservation_id || $$, $$ || table_id || $$)
        $$, 'P0001');
    end;
$test$;
rollback;