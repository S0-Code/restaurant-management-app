set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : SERVICES (BR-07 Chevauchement de services)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
    begin
        raise notice 'TEST: Insertion de deux services distincts (Midi et Soir) le même jour';

        -- 1. Premier service : 12:00 -> 14:00 (Lundi = 1)
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '12:00:00', '14:00:00');

        -- 2. Deuxième service : 19:00 -> 22:30 (Lundi = 1)
        -- Aucun chevauchement, doit passer.
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '19:00:00', '22:30:00');
    end
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : Chevauchement au début */
begin;
do $test$
    begin
        raise notice 'TEST: Nouveau service qui commence PENDANT un service existant (doit échouer)';

        -- Préparation : Service existant 12:00 -> 14:00
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '12:00:00', '14:00:00');

        -- Tentative : 13:00 -> 15:00 (Chevauche de 13h à 14h)
        perform should_fail($$
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '13:00:00', '15:00:00');
    $$, 'restrict_violation');
    end
$test$;
rollback;


/* Négatif 2 : Chevauchement à la fin */
begin;
do $test$
    begin
        raise notice 'TEST: Nouveau service qui finit PENDANT un service existant (doit échouer)';

        -- Préparation : Service existant 12:00 -> 14:00
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '12:00:00', '14:00:00');

        -- Tentative : 11:00 -> 12:30 (Chevauche de 12h à 12h30)
        perform should_fail($$
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '11:00:00', '12:30:00');
    $$, 'restrict_violation');
    end
$test$;
rollback;


/* Négatif 3 : Inclusion totale */
begin;
do $test$
    begin
        raise notice 'TEST: Nouveau service qui englobe totalement un service existant (doit échouer)';

        -- Préparation : Service existant 12:00 -> 14:00
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '12:00:00', '14:00:00');

        -- Tentative : 11:00 -> 15:00
        perform should_fail($$
        insert into services (restaurant, day_of_week, start_time, end_time)
        values (1, 1, '11:00:00', '15:00:00');
    $$, 'restrict_violation');
    end
$test$;
rollback;