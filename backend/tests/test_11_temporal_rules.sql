set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : RÉSERVATIONS (Transitions Temporelles)
   ========================================================================= */

/* Le statut d'une réservation peut passer de 'confirmed' à 'pending'
   uniquement si la réservation est dans le futur. */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */

begin;
do $test$
    begin
        raise notice 'TEST: INSERT et UPDATE pour une réservation DANS LE FUTUR (autorisés)';

        -- 1. TEST INSERT : On crée une réservation cobaye DANS LE FUTUR (dans 10 jours)
        insert into reservations (id, client, restaurant, number_of_guests, status, datetime)
        values (999, 3, 1, 2, 'confirmed', get_current_time() + interval '10 days');

        -- 2. TEST UPDATE : On met à jour ce cobaye vers pending
        update reservations set status = 'pending' where id = 999;
    end
$test$;
rollback;

/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

begin;
do $test$
    begin
        raise notice 'TEST: UPDATE de confirmed à pending DANS LE PASSÉ (doit échouer)';

        -- 1. Préparation (INSERT) : On crée un cobaye DANS LE PASSÉ
        insert into reservations (id, client, restaurant, number_of_guests, status, datetime)
        values (888, 3, 1, 2, 'confirmed', get_current_time() - interval '1 day');

        -- 2. TEST UPDATE Négatif : On tente de repasser ce cobaye en pending
        perform should_fail($$
            update reservations set status = 'pending' where id = 888;
        $$, 'restrict_violation');
    end
$test$;
rollback;