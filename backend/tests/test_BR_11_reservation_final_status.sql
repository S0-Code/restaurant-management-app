set search_path to public;

/* =========================================================================
   TESTS BR-11 (Pas de modif sur statut final)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TEST POSITIF (Modif autorisée sur pending)
   ------------------------------------------------------------------------- */

begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        res_id bigint;
        target_date timestamp := get_current_time() + interval '2 hours';
    begin
        raise notice 'TEST: Modification d''une réservation "pending" (autorisé)';

        insert into users (email, full_name, password, role, phone)
        values ('cl_ok_11@test.com', 'Client BR11 OK', 'Pass123.', 'client', '0400112200') returning id into client_id;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR11 OK', 'Avenue de la Renaissance 200', 'Bruxelles', '+32 2 555 00 00', 30) returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'pending') returning id into res_id;

        -- Doit réussir
        update reservations set number_of_guests = 4 where id = res_id;
    end;
$test$;
rollback;

/* -------------------------------------------------------------------------
   TESTS NÉGATIFS
   ------------------------------------------------------------------------- */
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        res_id bigint;
        target_date timestamp := get_current_time() + interval '5 hours';
    begin
        raise notice 'TEST: Modification d''une réservation "completed" (doit échouer)';

        -- Setup : Données de base
        insert into users (email, full_name, password, role, phone)
        values ('cl_ko1_11@test.com', 'Client BR11 KO1', 'Pass123.', 'client', '0400112201') returning id into client_id;
        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR11 KO1', 'Boulevard de l''Empereur 50', 'Bruxelles', '+32 2 555 00 01', 30) returning id into restaurant_id;
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        -- Désactiver les sécurités juste pour créer le cas de test
        alter table reservations disable trigger user;

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'completed') returning id into res_id;

        -- RÉACTIVATION des triggers pour le test réel
        alter table reservations enable trigger user;

        -- Tentative de modification (doit être bloqué par BR-11)
        perform should_fail(
                'update reservations set number_of_guests = 8 where id = ' || res_id,
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
        res_id bigint;
        target_date timestamp := get_current_time() + interval '1 day';
    begin
        raise notice 'TEST: Modification d''une réservation "cancelled" (doit échouer)';

        insert into users (email, full_name, password, role, phone)
        values ('cl_ko2_11@test.com', 'Client BR11 KO2', 'Pass123.', 'client', '0400112202') returning id into client_id;
        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto BR11 KO2', 'Chaussée de Wavre 500', 'Bruxelles', '+32 2 555 00 02', 30) returning id into restaurant_id;
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        -- Bypass pour setup
        alter table reservations disable trigger user;
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'cancelled') returning id into res_id;
        alter table reservations enable trigger user;

        -- Test BR-11
        perform should_fail(
                'update reservations set datetime = get_current_time() + interval ''10 days'' where id = ' || res_id,
                'raise_exception'
                );
    end;
$test$;
rollback;