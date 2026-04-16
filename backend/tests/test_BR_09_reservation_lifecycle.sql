set search_path to public;

/* =========================================================================
   RÈGLES MÉTIER : RÉSERVATIONS (BR-09 Cycle de vie)
   ========================================================================= */

/* -------------------------------------------------------------------------
   TESTS POSITIFS (Autorisés)
   ------------------------------------------------------------------------- */
begin;
do $test$
begin
        raise notice 'TEST: INSERT en pending et UPDATE vers confirmed (autorisés)';

        -- 1. INSERT valide (pending)
insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
values (999, 3, 1, current_timestamp + interval '2 days', 2, 'pending');

-- 2. Transition valide (pending -> confirmed)
update reservations set status = 'confirmed' where id = 999;
end
$test$;
rollback;


/* -------------------------------------------------------------------------
   TESTS NÉGATIFS (Doivent échouer)
   ------------------------------------------------------------------------- */

/* Négatif 1 : INSERT avec un statut interdit */
begin;
do $test$
begin
        raise notice 'TEST: INSERT d''une réservation directement en "confirmed" (doit échouer)';

        perform should_fail($$
            insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
            values (888, 3, 1, current_timestamp + interval '2 days', 2, 'confirmed');
        $$, 'restrict_violation');
end
$test$;
rollback;


/* Négatif 2 : Transition interdite (Saut d'étape) */
begin;
do $test$
begin
        raise notice 'TEST: Transition de "pending" à "completed" sans passer par confirmed (doit échouer)';

        -- Préparation d'une réservation valide
insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
values (777, 3, 1, current_timestamp + interval '2 days', 2, 'pending');

-- Tentative de saut d'étape (pending -> completed)
perform should_fail($$
            update reservations set status = 'completed' where id = 777;
        $$, 'restrict_violation');
end
$test$;
rollback;