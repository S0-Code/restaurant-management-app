/*
(BR-14) Une réservation ne peut pas être créée dans le passé
(ne doit être vérifié qu'au moment de la création).
*/

begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Réservation dans le futur correct (insert)';

        insert into system_time (simulated_time)
        values ('2026-04-24 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br14_ok@test.com', 'Client BR-14 OK', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR14 OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 5, '12:00:00', '14:00:00');

        insert into reservations (client, restaurant, number_of_guests, datetime)
        values (client_id, restaurant_id, 2, '2026-04-24 13:00:00');

    end;
$test$;
rollback;


begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Réservation dans le passé incorrect (insert)';

        delete from system_time;

        insert into system_time (simulated_time)
        values ('2026-04-24 12:00:00');

        insert into users (email, full_name, password, role)
        values ('client_br14_ko@test.com', 'Client BR-14 KO', 'Password123.', 'client')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR14 KO', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 5, '11:00:00', '14:00:00');

        perform should_fail(
                'insert into reservations (client, restaurant, number_of_guests, datetime)
                 values (' || client_id || ', ' || restaurant_id || ', 2, ''2026-04-24 11:00:00'')',
                'raise_exception'
                );

    end;
$test$;
rollback;