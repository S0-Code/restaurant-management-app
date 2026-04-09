set search_path to public, auth;

/*  Le statut d'une réservation doit être soit
    pending (en attente de confirmation),
    confirmed (confirmée),
    cancelled (annulée) ou
    completed (terminée suite à la venue effective du client).
*/

begin;
do $test$
    begin
        raise notice 'TEST: status correct (insert)';
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', '3', 'pending');
    end
    $test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: status incorrect (insert)';
        perform should_fail($$
            insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', 3, 'incorrect_status')
            $$, 'invalid_text_representation');
    end
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: status correct (update)';
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', '3', 'pending');

        UPDATE reservations
        SET status = 'cancelled'
        where
            client = 1 AND
            restaurant = 1;
    end
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: status incorrect (update)';
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', '3', 'pending');
        perform should_fail($$
            UPDATE reservations
        SET status = 'incorrect_status'
        where
            client = 1 AND
            restaurant = 1
            $$, 'invalid_text_representation')
        ;
    end
$test$;
rollback;


/*
Le nombre de convives d'une réservation doit être strictement positif.
*/

begin;
do $test$
    begin
        raise notice 'TEST: number of guests correct (insert)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending');

    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: number of guests incorrect (insert)';

        perform should_fail($$
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', 0, 'completed')
    $$, 'check_violation');

    end;
$test$;
rollback;

begin;
do $test$
    declare
        res_id int;
    begin
        raise notice 'TEST: number of guests correct (update)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending')
        returning id into res_id;

        update reservations
        set number_of_guests = 2
        where id = res_id;

    end;
$test$;
rollback;

begin;
do $test$
    declare
        res_id int;
    begin
        raise notice 'TEST: status incorrect (update)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending')
        returning id into res_id;

        perform should_fail($$
        update reservations
        set number_of_guests = 0
        where id = $$ || res_id
            , 'check_violation');

    end;
$test$;
rollback;

/*
Le texte des demandes spéciales d'une réservation (special_requests),
s'il est défini, doit avoir une longueur minimale de 10 caractères.
*/

begin;
do $test$
    begin
        raise notice 'TEST: Longueur de special_requests >= 10 correct (insert)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending', 'Sans oignons');

    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST: Longueur de special_requests >= 10 incorrect (insert)';

        perform should_fail($$
            insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
            values (1, 1, '2024-11-15 19:00:00', 3, 'pending', 'tropCourt')
        $$, 'check_violation');

    end;
$test$;
rollback;


begin;
do $test$
    declare
        reservation_id int;
    begin
        raise notice 'TEST: Longueur de special_requests >= 10 correct (update)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending', null)
        returning id into reservation_id;

        update reservations
        set special_requests = 'Table au fond'
        where id = reservation_id;

    end;
$test$;
rollback;


begin;
do $test$
    declare
        reservation_id int;
    begin
        raise notice 'TEST: Longueur de special_requests >= 10 incorrect (update)';

        insert into reservations (client, restaurant, datetime, number_of_guests, status, special_requests)
        values (1, 1, '2024-11-15 19:00:00', 3, 'pending', null)
        returning id into reservation_id;

        perform should_fail($$
            update reservations
            set special_requests = 'court'
            where id = $$ || reservation_id
            , 'check_violation');

    end;
$test$;
rollback;