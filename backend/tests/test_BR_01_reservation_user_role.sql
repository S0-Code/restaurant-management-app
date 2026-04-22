set search_path to public, auth;

begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST:  Réservation liée à un client(pas manager) correct (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br01_ok@test.com', 'Client BR-01', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone)
        values ('Test Resto', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_id;



        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 3,  '2026-11-15 19:00:00.000000');

    end;
$test$;
rollback;


begin;
do $test$
    declare
        owner_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST : Réservation liée à un client(pas manager) incorrect (insert)';

        insert into users (email, full_name, password, role)
        values ('client_br01_ok@test.com', 'Client BR-01', 'Password123.', 'manager')
        returning id into owner_id;

        insert into restaurants (name, address, city, phone)
        values ('Test Resto', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_id;

        perform should_fail($$
        insert into reservations (client, restaurant, number_of_guests, datetime)
        values ($$ || owner_id || $$, $$ || restaurant_id || $$, 3,  '2026-11-15 19:00:00.000000') $$, 'raise_exception'
    );

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client1_id bigint;
        client2_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: Réservation liée à un client correct (update)';

        insert into users (email, full_name, password, role)
        values ('client1_br01_update_ok@test.com', 'Client 1 BR-01', 'Password123.', 'client')
        returning id into client1_id;

        insert into users (email, full_name, password, role)
        values ('client2_br01_update_ok@test.com', 'Client 2 BR-01', 'Password123.', 'client')
        returning id into client2_id;

        insert into restaurants (name, address, city, phone)
        values ('Test Resto', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_id;

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client1_id, restaurant_id, 3, '2026-11-15 19:00:00.000000')
        returning id into reservation_id;

        update reservations
        set client = client2_id
        where id = reservation_id;

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        manager_id bigint;
        restaurant_id bigint;
        reservation_id bigint;
    begin
        raise notice 'TEST: Réservation liée à un utilisateur non client incorrect (update)';

        insert into users (email, full_name, password, role)
        values ('client_br01_update_ko@test.com', 'Client BR-01', 'Password123.', 'client')
        returning id into client_id;

        insert into users (email, full_name, password, role)
        values ('manager_br01_update_ko@test.com', 'Manager BR-01', 'Password123.', 'manager')
        returning id into manager_id;

        insert into restaurants (name, address, city, phone)
        values ('Test Resto', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12')
        returning id into restaurant_id;

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 3, '2026-11-15 19:00:00.000000')
        returning id into reservation_id;

        perform should_fail($$
            update reservations
            set client = $$ || manager_id || $$
            where id = $$ || reservation_id ||
            $$$$, 'raise_exception');

    end;
$test$;
rollback;