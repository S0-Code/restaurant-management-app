set search_path to public;

/* =========================================================================
   TESTS BR-12 (Pas de tables si pending/cancelled)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TEST POSITIF
   ------------------------------------------------------------------------- */
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res_id bigint;
        target_date timestamp := get_current_time() + interval '5 hours';
    begin
        raise notice 'TEST: Association de table autorisée sur une réservation "confirmed"';

        -- Setup standard
        insert into users (email, full_name, password, role, phone) values ('cl_br12_ok@test.com', 'Client BR12 OK Unique', 'Pass123.', 'client', '0400120000') returning id into client_id;
        insert into restaurants (name, address, city, phone, slot_duration) values ('Resto BR12 OK', 'Avenue des Arts 1500', 'Bruxelles', '+32 2 555 12 12', 30) returning id into restaurant_id;
        insert into tables (restaurant, table_number, capacity) values (restaurant_id, 1, 4) returning id into table_id;
        insert into services (restaurant, day_of_week, start_time, end_time) values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'pending') returning id into res_id;

        -- BYPASS pour passer en confirmed sans être bloqué par la BR-02 (capacité)
        alter table reservations disable trigger user;
        update reservations set status = 'confirmed' where id = res_id;
        alter table reservations enable trigger user;

        -- L'insertion dans reservation_tables doit maintenant RÉUSSIR car le statut est 'confirmed'
        insert into reservation_tables (reservation, "table") values (res_id, table_id);
    end;
$test$;
rollback;

/* -------------------------------------------------------------------------
   TESTS NÉGATIFS
   ------------------------------------------------------------------------- */

-- 1. Ajout de table sur réservation PENDING
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res_id bigint;
        target_date timestamp := get_current_time() + interval '5 hours';
    begin
        raise notice 'TEST: Ajouter une table à une réservation "pending" (doit échouer)';

        insert into users (email, full_name, password, role, phone) values ('cl_br12_ko1@test.com', 'Client BR12 KO1 Unique', 'Pass123.', 'client', '0400120001') returning id into client_id;
        insert into restaurants (name, address, city, phone, slot_duration) values ('Resto BR12 KO1', 'Rue de la Loi 2000', 'Bruxelles', '+32 2 555 12 13', 30) returning id into restaurant_id;
        insert into tables (restaurant, table_number, capacity) values (restaurant_id, 1, 4) returning id into table_id;
        insert into services (restaurant, day_of_week, start_time, end_time) values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'pending') returning id into res_id;

        -- Doit échouer via BR-12
        perform should_fail(
                'insert into reservation_tables (reservation, "table") values (' || res_id || ', ' || table_id || ')',
                'raise_exception'
                );
    end;
$test$;
rollback;

-- 2. Retour vers PENDING alors qu'une table est associée
begin;
do $test$
    declare
        client_id bigint;
        restaurant_id bigint;
        table_id bigint;
        res_id bigint;
        target_date timestamp := get_current_time() + interval '5 hours';
    begin
        raise notice 'TEST: Passer en "pending" une réservation avec table (doit échouer)';

        insert into users (email, full_name, password, role, phone) values ('cl_br12_ko2@test.com', 'Client BR12 KO2 Unique', 'Pass123.', 'client', '0400120002') returning id into client_id;
        insert into restaurants (name, address, city, phone, slot_duration) values ('Resto BR12 KO2', 'Boulevard du Régent 3000', 'Bruxelles', '+32 2 555 12 14', 30) returning id into restaurant_id;
        insert into tables (restaurant, table_number, capacity) values (restaurant_id, 1, 4) returning id into table_id;
        insert into services (restaurant, day_of_week, start_time, end_time) values (restaurant_id, extract(isodow from target_date), '00:00:00', '23:59:59');

        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        values (client_id, restaurant_id, target_date, 2, 'pending') returning id into res_id;

        -- Bypass pour setup : on met une table sur une confirmed de force
        alter table reservations disable trigger user;
        alter table reservation_tables disable trigger user;
        update reservations set status = 'confirmed' where id = res_id;
        insert into reservation_tables (reservation, "table") values (res_id, table_id);
        alter table reservations enable trigger user;
        alter table reservation_tables enable trigger user;

        -- Tentative de retour en pending (doit échouer via BR-12)
        perform should_fail(
                'update reservations set status = ''pending'' where id = ' || res_id,
                'raise_exception'
                );
    end;
$test$;
rollback;