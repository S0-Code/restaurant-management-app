set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : RÉSERVATIONS (BR-13 Pas de doublon client par service)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Client faisant une seule réservation pour un service (autorisé)';

        -- Setup
        insert into users (email, full_name, password, role, phone)
        values ('client_br13_ok@test.com', 'Client OK', 'Pass123.', 'client', '0470112233')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR13 OK', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        -- Service du Vendredi (jour 5) de 18h à 22h
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 5, '18:00:00', '22:00:00');

        -- Insertion (doit réussir)
        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-20 19:00:00', 'pending');
    end;
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : Deux réservations pending le même jour dans le même service (Même heure) */
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
    begin
        raise notice 'TEST: Deux réservations dans le même service (doit échouer)';

        -- Setup
        insert into users (email, full_name, password, role, phone)
        values ('client_br13_ko1@test.com', 'Client KO1', 'Pass123.', 'client', '0470112233')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR13 KO1', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        -- Service du Vendredi (jour 5) de 18h à 22h
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 5, '18:00:00', '22:00:00');

        -- Première réservation à 19h00 (réussit)
        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-20 19:00:00', 'pending');

        -- Tentative de deuxième réservation à 19h00, même jour, même service (échoue)
        perform should_fail(
                'insert into reservations (client, restaurant, number_of_guests, datetime, status)
                 values (' || client_id || ', ' || restaurant_id || ', 2, ''2026-11-20 19:00:00'', ''pending'')',
                'raise_exception'
                );
    end;
$test$;
rollback;


/* Négatif 2 : Deux réservations pending dans le même service (Heures différentes) */
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        res1_id bigint;
    begin
        raise notice 'TEST: Doublon dans le même service mais à des heures différentes (doit échouer)';

        -- Setup
        insert into users (email, full_name, password, role, phone)
        values ('client_br13_ko2@test.com', 'Client KO2', 'Pass123.', 'client', '0470112233')
        returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR13 KO2', 'Rue du Test', 'Bruxelles', '+32 485 65 69 12', 30)
        returning id into restaurant_id;

        -- Service du Vendredi (jour 5) de 18h à 22h
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 5, '18:00:00', '22:00:00');

        -- Réservation initiale à 19h00
        insert into reservations (client, restaurant, number_of_guests, datetime, status)
        values (client_id, restaurant_id, 2, '2026-11-20 19:00:00', 'pending')
        returning id into res1_id;

        -- Le client tente de refaire une réservation à 20h30 dans le même service (sans passer la première en confirmed)
        perform should_fail(
                'insert into reservations (client, restaurant, number_of_guests, datetime, status)
                 values (' || client_id || ', ' || restaurant_id || ', 4, ''2026-11-20 20:30:00'', ''pending'')',
                'raise_exception'
                );
    end;
$test$;
rollback;