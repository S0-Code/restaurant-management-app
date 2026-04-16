set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : SERVICES (day_of_week)
   ========================================================================= */

/* Le jour de la semaine doit être compris entre 1 (lundi) et 7 (dimanche). */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */

/* Test Positif : INSERT valide */
begin;
do $test$
    begin
        raise notice 'TEST: Insertion d''un jour valide (4 = Jeudi)';

        -- On prépare un restaurant cobaye
        insert into restaurants (id, name, address, city, phone)
        values (999, 'Test Resto', 'Rue du Test', 'Bruxelles', '0470112233');

        -- On insère un service valide (Jour 4)
        insert into services (id, restaurant, day_of_week, start_time, end_time)
        values (999, 999, 4, '12:00', '14:30');
    end
$test$;
rollback;

/* Test Positif : UPDATE valide */
begin;
do $test$
    begin
        raise notice 'TEST: Mise à jour d''un jour valide (1 = Lundi) sur un service existant';

        -- On modifie un service qui existe déjà
        update services set day_of_week = 1 where id = 1;
    end
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS
   ------------------------------------------------------------------------- */

/* Test Négatif : INSERT invalide */
begin;
do $test$
    begin
        raise notice 'TEST: Insertion jour invalide (8) - doit échouer';

        insert into restaurants (id, name, address, city, phone)
        values (999, 'Test Resto', 'Rue du Test', 'Bruxelles', '0470112233');

        perform should_fail($$
            insert into services (id, restaurant, day_of_week, start_time, end_time)
            values (999, 999, 8, '12:00', '14:30');
        $$, 'check_violation');
    end
$test$;
rollback;

/* Test Négatif : UPDATE invalide */
begin;
do $test$
    begin
        raise notice 'TEST: Mise à jour vers jour invalide (0) sur un service existant - doit échouer';

        perform should_fail($$
            -- On tente de modifier un service existant avec un jour hors limite
            update services set day_of_week = 0 where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;


/* On ne peut pas modifier le restaurant d'un service. */

begin;
do
$test$
    declare
        service_id bigint;
        restaurant_id_1 bigint;
    begin
        raise notice 'TEST: restaurant inchangé correct (update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto test 1', 'Rue du Test 1', 'Bruxelles', '0470000001', 30)
        returning id into restaurant_id_1;


        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id_1, 1, '12:00:00', '17:00:00')
        returning id into service_id;

        update services
        set day_of_week = 3
        where id = service_id;

    end;
$test$;
rollback;


begin;
do
$test$
    declare
        service_id bigint;
        restaurant_id_1 bigint;
        restaurant_id_2 bigint;
    begin
        raise notice 'TEST: restaurant modifié incorrect (update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto test 3', 'Rue du Test 3', 'Bruxelles', '0470000003', 30)
        returning id into restaurant_id_1;

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Resto test 4', 'Rue du Test 4', 'Bruxelles', '0470000004', 30)
        returning id into restaurant_id_2;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id_1, 4, '13:00:00', '20:00:00')
        returning id into service_id;

        perform should_fail($$
        update services
        set restaurant = $$ || restaurant_id_2 || $$
        where id = $$ || service_id ||
            $$$$, 'restrict_violation');

end;
$test$;
rollback;


/* L'heure de fin doit être postérieure à l'heure de début d'au moins une heure.
   Note : l'heure de fin d'un service représente l'heure au-delà de laquelle le restaurant
   n'accepte plus de clients.*/

begin;
do $test$
    DECLARE
        restaurant_id bigint;
    begin
        raise notice 'TEST: End time >= Start_time + 1h correct (Insert)';

        insert into restaurants (name, address, city, phone, slot_duration)
        VALUES ('Test end time après start time', 'xxxxxxxxxxx', 'BXL', '+32 459 63 56 99', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        VALUES (restaurant_id, 6, '11:00:00', '12:00:00' );
    end;
$test$;
rollback;

begin;
do $test$
    DECLARE
        restaurant_id bigint;
    begin
        raise notice 'TEST: End time >= Start_time + 1h Incorrect (Insert)';

        insert into restaurants (name, address, city, phone, slot_duration)
        VALUES ('Test end time après start time', 'xxxxxxxxxxx', 'BXL', '+32 459 63 56 99', 30)
        returning id into restaurant_id;

        perform should_fail($$
                insert into services (restaurant, day_of_week, start_time, end_time)
                VALUES ($$ || restaurant_id || $$, 6, '11:00:00', '11:59:59' )
            $$, 'check_violation')
        ;
    end;
$test$;
rollback;

begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST: End time >= Start_time + 1h correct (Update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Test end time après start time', 'xxxxxxxxxxx', 'BXL', '+32 459 63 56 99', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 6, '11:00:00', '12:00:00')
        returning id into service_id;

        update services
        set end_time = '12:30:00'
        where id = service_id;
    end;
$test$;
rollback;


begin;
do $test$
    declare
        restaurant_id bigint;
        service_id bigint;
    begin
        raise notice 'TEST: End time >= Start_time + 1h incorrect (Update)';

        insert into restaurants (name, address, city, phone, slot_duration)
        values ('Test end time après start time', 'xxxxxxxxxxx', 'BXL', '+32 459 63 56 99', 30)
        returning id into restaurant_id;

        insert into services (restaurant, day_of_week, start_time, end_time)
        values (restaurant_id, 6, '11:00:00', '12:00:00')
        returning id into service_id;

        perform should_fail(
                format($sql$
                update services
                set end_time = '11:30:00'
                where id = %s
            $sql$, service_id),
                'check_violation'
                );
    end;
$test$;
rollback;