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